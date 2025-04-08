const { io } = require("socket.io-client");
const fs = require("fs");
const path = require("path");
const http = require("http");
const https = require("https");
const { execFile } = require("child_process");
const os = require("os");
const querystring = require("querystring");

const socket = io("http://localhost:3999");
let currentTask = null;

const basePath = path.join(__dirname, "autoit Wilcom");
const imagePath = path.join(basePath, "design", "oke.png");
const exePath = path.join(basePath, "main.exe");

// ======= Hàm tải ảnh thông minh (dùng https.get) =======
function downloadImage(url, savePath) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(savePath);
    const client = url.startsWith("https") ? https : http;

    client.get(url, (res) => {
      if (res.statusCode !== 200) {
        return reject(new Error(`HTTP ${res.statusCode}`));
      }

      res.pipe(file);
      file.on("finish", () => file.close(resolve));
    }).on("error", reject);
  });
}

// ======= Kết nối tới server trung tâm =======
socket.on("connect", () => {
  console.log("✅ Đã kết nối tới server");
  socket.emit("status", "available");
});

// ======= Nhận task từ server =======
socket.on("task", async (task) => {
  console.log("📥 Nhận task:", task);
  socket.emit("status", "busy");
  currentTask = task;

  const { urlImage, orderID } = task;

  try {
    // Tạo thư mục nếu chưa có
    fs.mkdirSync(path.dirname(imagePath), { recursive: true });

    // Tải ảnh
    await downloadImage(urlImage, imagePath);
    console.log("🖼️ Ảnh đã lưu:", imagePath);

    // Gọi AutoIt exe
    execFile(exePath, [orderID], (err) => {
      if (err) {
        console.error("❌ Lỗi chạy exe:", err);
        sendResult(orderID, 0, "fail", err.message);
        socket.emit("done");
      } else {
        console.log("▶️ AutoIt đang xử lý...");
        // Chờ AutoIt gọi lại /notify
      }
    });
  } catch (error) {
    console.error("❌ Lỗi tải ảnh:", error);
    sendResult(orderID, 0, "fail", "download_error");
    socket.emit("done");
  }
});

// ======= Nhận stitch từ AutoIt qua localhost:3458 =======
http.createServer((req, res) => {
  if (req.method === "POST" && req.url === "/notify") {
    let body = "";
    req.on("data", chunk => body += chunk);
    req.on("end", () => {
      const parsed = querystring.parse(body);
      const stitch = parseInt(parsed.data || "0");

      if (!currentTask) {
        console.error("❌ Không có task để xử lý!");
        res.writeHead(400);
        return res.end("No task");
      }

      const { orderID } = currentTask;
      sendResult(orderID, stitch);
      socket.emit("done");
      currentTask = null;

      res.writeHead(200);
      res.end("OK");
    });
  } else if (req.method === "POST" && req.url === "/errWilcom") {
    let body = "";
    req.on("data", chunk => body += chunk);
    req.on("end", () => {
      const parsed = querystring.parse(body);
      const typeErr = parsed.data || "unknown_error";

      if (!currentTask) {
        console.error("❌ Không có task để xử lý lỗi!");
        res.writeHead(400);
        return res.end("No task");
      }

      const { orderID } = currentTask;
      sendErr(orderID, typeErr);
      socket.emit("done");
      currentTask = null;

      res.writeHead(200);
      res.end("ERR received");
    });
  }

  else {
    res.writeHead(404);
    res.end();
  }
}).listen(3458, () => {
  console.log("📡 Client đang chờ AutoIt gọi /notify tại cổng 3458");
});

// ======= Gửi kết quả về server trung tâm =======
function sendResult(orderID, stitch) {
  const data = JSON.stringify({ orderID, stitch});

  const req = http.request({
    hostname: "localhost",
    port: 3999,
    path: "/result",
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Content-Length": data.length
    }
  }, res => {
    console.log(`📤 Kết quả đã gửi (HTTP ${res.statusCode})`);
  });

  req.on("error", err => {
    console.error("❌ Lỗi gửi kết quả:", err);
  });

  req.write(data);
  req.end();
}

function sendErr(orderID, message) {
  const data = JSON.stringify({
    orderID,
    status: "fail",
    statusValue: message
  });

  const req = http.request({
    hostname: "http://192.168.1.194",
    port: 3999,
    path: "/runErr", // vẫn gửi về /result
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Content-Length": data.length
    }
  }, res => {
    console.log(`📤 Lỗi đã gửi về server (HTTP ${res.statusCode})`);
  });

  req.on("error", err => {
    console.error("❌ Lỗi khi gửi lỗi:", err);
  });

  req.write(data);
  req.end();
}
