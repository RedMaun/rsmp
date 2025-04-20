const axios = require("axios");
const fsasync = require("fs/promises");
const fs = require("fs");
const path = require("path");
const admzip = require("adm-zip");
const { spawn } = require("child_process");

const ver_file = path.join(__dirname, "ver.txt");
const start_bat_file = path.join(__dirname, "start.bat");
const update_url = "https://api.github.com/repos/Redmaun/rsmp/releases/latest";
const download_url =
  "https://github.com/RedMaun/rsmp/releases/latest/download/";

const game_zip_url = download_url + "game.zip";
const diff_zip_url = download_url + "diff.zip";
const start_bat_url = download_url + "start.bat";

const minecraft_dir = "/.tlauncher/legacy/Minecraft";
const game_path = path.join(process.env.APPDATA, minecraft_dir + "/game");
const mods_path = path.join(process.env.APPDATA, minecraft_dir + "/game/mods");
const laucnher_path = path.join(process.env.APPDATA, minecraft_dir + "/TL.exe");

const update_ver_file = (version) => {
  fs.writeFileSync(ver_file, version);
};

const does_file_exists = async (file_name) => {
  try {
    const file = path.join(__dirname, file_name);
    await fsasync.access(file);
    return true;
  } catch (err) {
    return false;
  }
};

const get_local_ver = async () => {
  try {
    const data = await fsasync.readFile(ver_file, "utf8");
    return data;
  } catch (err) {
    console.error("Error reading file:", err);
  }
};

const get_github_data = async () => {
  const response = await axios.get(update_url);
  return response.data;
};

const get_type_of_update = (data) => {
  data.assets.forEach((element) => {
    if (element.name === "diff.zip") {
      return "diff";
    }
  });
  return "full";
};

const download_file = async (url, file_path) => {
  const response = await axios({
    method: "GET",
    url: url,
    responseType: "stream",
  });

  const writer = fs.createWriteStream(file_path);
  return new Promise((resolve, reject) => {
    response.data.pipe(writer);

    writer.on("finish", () => {
      resolve();
    });

    writer.on("error", (err) => {
      reject(err);
    });
  });
};

const update_start_bat = async () => {
  await download_file(start_bat_url, start_bat_file);
};

const launch_client = () => {
  spawn(laucnher_path, {
    detached: true,
    stdio: "ignore",
  }).unref();
  process.exit(0);
};

const check_update = async () => {
  const local_ver = await get_local_ver();
  const github_data = await get_github_data();
  const global_ver = github_data.name;
  if (local_ver !== global_ver) {
    await update_start_bat();
    const type_of_update = get_type_of_update(github_data);
    if (type_of_update == "diff") await diff_update();
    if (type_of_update == "full") await full_update();
  }
  launch_client();
};

const unzip = async (zip_path, extractToPath) => {
  const zip = new admzip(zip_path);
  const entries = zip.getEntries();

  entries.forEach(async (entry) => {
    const full_path = path.join(extractToPath, entry.entryName);

    if (entry.isDirectory) return;

    const dir = path.dirname(full_path);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(full_path, entry.getData());
  });
};

const diff_update = async () => {
  console.log("Performing diff update...");
  const temp_path = path.join(__dirname, "diff.zip");
  await download_file(diff_zip_url, temp_path);
  await unzip(temp_path, game_path);
  await fsasync.unlink(temp_path);
  const global_ver = (await get_github_data()).name;
  update_ver_file(global_ver);
};

const full_update = async () => {
  console.log("Performing full update...");
  const temp_path = path.join(__dirname, "game.zip");
  await download_file(game_zip_url, temp_path);
  for (const file of await fsasync.readdir(mods_path)) {
    await fsasync.unlink(path.join(mods_path, file));
  }
  await unzip(temp_path, game_path);
  await fsasync.unlink(temp_path);
  const global_ver = (await get_github_data()).name;
  update_ver_file(global_ver);
};

(async () => {
  does_file_exists(ver_file) === false ? full_update() : check_update();
})();
