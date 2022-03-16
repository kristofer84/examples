var { Tar, Untar } = require("tar-async");
const fs = require("fs");
const MemoryStream = require("memorystream");
const { runMain } = require("module");

const files = [
  { filename: "file1.txt", content: "content1" },
  { filename: "file2.txt", content: "content2" },
];
const tarfile = "tarball.tar";

async function run() {
  await tar(tarfile, files);
  console.log("a");
  files.push({ filename: "file3.txt", content: "content3" });

  await tar(tarfile, files);
}

async function tar(tarfile, files) {
  const memStream = new MemoryStream();
  const tar = new Tar({ output: memStream });

  const existing = [];

  if (fs.existsSync(tarfile)) {
    const untar = new Untar(function (_err, header, fileStream) {
      console.log("appending: " + header.filename);
      existing.push(header.filename);
      fileStream.on("data", function (data) {
        tar.append(header.filename, data.toString());
      });
    });

    fs.createReadStream(tarfile).pipe(untar);
  }

  for (const { filename, content } of files) {
    //Skip existing filenames
    if (existing.includes(filename)) {
      console.log("skipping " + filename);
      continue;
    }
    console.log("adding " + filename);

    tar.append(filename, content);
  }

  tar.close();

  //Create a file
  const out = fs.createWriteStream(tarfile);

  //Write the memoryStream to disk
  memStream.pipe(out);

  out.on("error", function (err) {
    console.log(err);
  });
}

run();