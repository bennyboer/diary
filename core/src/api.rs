use std::fs;
use std::path::Path;

use zeroize::Zeroize;

pub fn save(file_path: String, mut password: String, data: String) {
    let path = Path::new(&file_path);
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).expect("Failed to create diary directory");
    }
    fs::write(&file_path, data).expect("Unable to write file");

    let target_file_path = format!("{}.encrypted", &file_path);
    vault_core::encrypt_file(&file_path, &target_file_path, &password).expect("Unable to encrypt file");

    fs::remove_file(&file_path).expect("Unable to remove file");

    password.zeroize();
}

pub fn load(file_path: String, mut password: String) -> String {
    let encrypted_file_path = format!("{}.encrypted", &file_path);

    let path = Path::new(&encrypted_file_path);
    if path.exists() {
        vault_core::decrypt_file(&encrypted_file_path, &file_path, &password).expect("Unable to decrypt file");

        let result = fs::read_to_string(&file_path).expect("Unable to read file");

        fs::remove_file(&file_path).expect("Unable to remove file");

        return result;
    }

    password.zeroize();

    return String::new();
}

pub fn list(folder: String) -> Vec<u32> {
    let path = Path::new(&folder);
    if !path.exists() {
        return Vec::new();
    }

    let mut dates = Vec::new();

    for entry in fs::read_dir(folder).expect("Unable to read directory") {
        let entry = entry.expect("Unable to read directory");
        let path = entry.path();
        if path.is_file() {
            let date = path.file_stem().unwrap().to_str().unwrap().parse::<u32>().unwrap();
            dates.push(date);
        }
    }

    dates
}
