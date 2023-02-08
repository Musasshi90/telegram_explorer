package com.example.telegram_explorer;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.util.Log;

import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Map;
import java.util.StringTokenizer;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FileUtilities {
    static String TAG = FileUtilities.class.getSimpleName();
    private Activity ac;
    public static final String getFiles = "getFileItem";
    public static final String openDirectory = "openDirectory";
    public static final int REQUEST_CODE_FILE = 4786;
    private MethodChannel.Result result;
    private static final int EOF = -1;
    private static final int DEFAULT_BUFFER_SIZE = 1024 * 4;

    public static boolean isFileMethod(MethodCall call) {
        if (call.method.equals(getFiles)) {
            return true;
        } else return call.method.equals(openDirectory);
    }

    public void fileChecking(MethodCall call, MethodChannel.Result result, Activity ac) {
        this.ac = ac;
        this.result = result;
        Log.e(TAG, "call.method:" + call.method);
        if (call.method.equals(getFiles)) {
            ArrayList<FileItem> fileItems = new ArrayList<FileItem>();
            fileItems.addAll(getFolderItem());
            fileItems.addAll(loadRecentFiles());
            Gson gson = new Gson();
            String json = gson.toJson(fileItems);
            result.success(json);
        } else if (call.method.equals(openDirectory)) {
            Map<String, Object> arguments = (Map<String, Object>) call.arguments;
            String json = (String) arguments.get("fileItem");
            this.result = result;
            Gson gson = new Gson();
            FileItem fileItem = gson.fromJson(json, FileItem.class);
            openDirectory(fileItem);
        }
    }

    private ArrayList<FileItem> getFolderItem() {
        ArrayList<FileItem> fileItems = new ArrayList<FileItem>();
        HashSet<String> paths = new HashSet<>();

        String defaultPath = Environment.getExternalStorageDirectory().getPath();
        String defaultPathState = Environment.getExternalStorageState();
        if (defaultPathState.equals(Environment.MEDIA_MOUNTED) || defaultPathState.equals(Environment.MEDIA_MOUNTED_READ_ONLY)) {
            FileItem fileItem = new FileItem();
            if (Environment.isExternalStorageRemovable()) {
                fileItem.setTitle("SD Card");
                fileItem.setStorage(true);
                fileItem.setDescription("Browse your external storage");
            } else {
                fileItem.setTitle("Internal Storage");
                fileItem.setStorage(true);
                fileItem.setDescription("Browse your file system");
            }
            fileItem.setRecentFile(false);
            fileItem.setFolder(true);
            fileItem.setPath(Environment.getExternalStorageDirectory().getPath());
            fileItems.add(fileItem);
            paths.add(defaultPath);
        }
        BufferedReader bufferedReader = null;
        try {
            bufferedReader = new BufferedReader(new FileReader("/proc/mounts"));
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                if (line.contains("vfat") || line.contains("/mnt")) {
                    Log.d(TAG, line);
                    StringTokenizer tokens = new StringTokenizer(line, " ");
                    String unused = tokens.nextToken();
                    String path = tokens.nextToken();
                    if (paths.contains(path)) {
                        continue;
                    }
                    if (line.contains("/dev/block/vold")) {
                        if (!line.contains("/mnt/secure") && !line.contains("/mnt/asec") && !line.contains("/mnt/obb") && !line.contains("/dev/mapper") && !line.contains("tmpfs")) {
                            if (!new File(path).isDirectory()) {
                                int index = path.lastIndexOf('/');
                                if (index != -1) {
                                    String newPath = "/storage/" + path.substring(index + 1);
                                    if (new File(newPath).isDirectory()) {
                                        path = newPath;
                                    }
                                }
                            }
                            paths.add(path);
                            try {
                                FileItem fileItem = new FileItem();
                                if (path.toLowerCase().contains("sd")) {
                                    fileItem.setTitle("SD Card");
                                } else {
                                    fileItem.setTitle("External Storage");
                                }
                                fileItem.setStorage(true);
                                fileItem.setRecentFile(false);
                                fileItem.setFolder(true);
                                fileItem.setDescription("Browse your external storage");
                                fileItem.setPath(path);
                                fileItems.add(fileItem);
                            } catch (Exception e) {
                                Log.e(TAG, e.toString());
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        } finally {
            if (bufferedReader != null) {
                try {
                    bufferedReader.close();
                } catch (Exception e) {
                    Log.e(TAG, e.toString());
                }
            }
        }
        return fileItems;
    }

    public ArrayList<FileItem> loadRecentFiles() {
        try {
            return checkDirectory(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS));
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return null;
    }

    private ArrayList<FileItem> checkDirectory(File rootDir) {
        File[] files = rootDir.listFiles();
        ArrayList<FileItem> fileItems = new ArrayList<>();
        if (files != null) {
            for (File file : files) {
                FileItem fileItem = new FileItem();
                fileItem.setTitle(file.getName());
                fileItem.setRecentFile(true);
                fileItem.setPath(file.getPath());
                fileItem.setFolder(file.isDirectory());
                fileItem.setStorage(false);
                String fname = file.getName();
                String[] sp = fname.split("\\.");
                fileItem.setExtension(sp.length > 1 ? sp[sp.length - 1] : "?");
                fileItem.setFileSize((int) file.length());
                fileItem.setDescription(formatFileSize(file.length()));
                fname = fname.toLowerCase();
                fileItems.add(fileItem);
            }
        }
        return fileItems;
    }

    public static String formatFileSize(long size) {
        return formatFileSize(size, false);
    }

    public static String formatFileSize(long size, boolean removeZero) {
        if (size < 1024) {
            return String.format("%d B", size);
        } else if (size < 1024 * 1024) {
            float value = size / 1024.0f;
            if (removeZero && (value - (int) value) * 10 == 0) {
                return String.format("%d KB", (int) value);
            } else {
                return String.format("%.1f KB", value);
            }
        } else if (size < 1024 * 1024 * 1024) {
            float value = size / 1024.0f / 1024.0f;
            if (removeZero && (value - (int) value) * 10 == 0) {
                return String.format("%d MB", (int) value);
            } else {
                return String.format("%.1f MB", value);
            }
        } else {
            float value = (int) (size / 1024L / 1024L) / 1000.0f;
            if (removeZero && (value - (int) value) * 10 == 0) {
                return String.format("%d GB", (int) value);
            } else {
                return String.format("%.2f GB", value);
            }
        }
    }


    private void openDirectory(FileItem fileItem) {
        File file = new File(fileItem.getPath());
        boolean isExternalStorageManager = false;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            isExternalStorageManager = Environment.isExternalStorageManager();
        }
        if (fileItem.isStorage() && !isExternalStorageManager) {
            Intent filePickerIntent = new Intent(Intent.ACTION_GET_CONTENT);
            if (Build.VERSION.SDK_INT >= 18) {
                filePickerIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
            }
            filePickerIntent.setType("*/*");
            ac.startActivityForResult(filePickerIntent, REQUEST_CODE_FILE);
        }
    }

    public static File from(Context context, Uri uri) throws IOException {
        InputStream inputStream = context.getContentResolver().openInputStream(uri);
        String fileName = getFileName(context, uri);
        String[] splitName = splitFileName(fileName);
        File tempFile = File.createTempFile(splitName[0], splitName[1]);
        tempFile = rename(tempFile, fileName);
        tempFile.deleteOnExit();
        FileOutputStream out = null;
        try {
            out = new FileOutputStream(tempFile);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        if (inputStream != null) {
            copy(inputStream, out);
            inputStream.close();
        }

        if (out != null) {
            out.close();
        }
        return tempFile;
    }

    private static String[] splitFileName(String fileName) {
        String name = fileName;
        String extension = "";
        int i = fileName.lastIndexOf(".");
        if (i != -1) {
            name = fileName.substring(0, i);
            extension = fileName.substring(i);
        }

        return new String[]{name, extension};
    }

    private static String getFileName(Context context, Uri uri) {
        String result = null;
        if (uri.getScheme().equals("content")) {
            Cursor cursor = context.getContentResolver().query(uri, null, null, null, null);
            try {
                if (cursor != null && cursor.moveToFirst()) {
                    result = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
        }
        if (result == null) {
            result = uri.getPath();
            int cut = result.lastIndexOf(File.separator);
            if (cut != -1) {
                result = result.substring(cut + 1);
            }
        }
        return result;
    }

    private static File rename(File file, String newName) {
        File newFile = new File(file.getParent(), newName);
        if (!newFile.equals(file)) {
            if (newFile.exists() && newFile.delete()) {
                Log.d("FileUtil", "Delete old " + newName + " file");
            }
            if (file.renameTo(newFile)) {
                Log.d("FileUtil", "Rename file to " + newName);
            }
        }
        return newFile;
    }

    private static long copy(InputStream input, OutputStream output) throws IOException {
        long count = 0;
        int n;
        byte[] buffer = new byte[DEFAULT_BUFFER_SIZE];
        while (EOF != (n = input.read(buffer))) {
            output.write(buffer, 0, n);
            count += n;
        }
        return count;
    }

    public boolean handleFileSelection(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_FILE) {
            if (resultCode == Activity.RESULT_OK) {
                if (data != null && data.getDataString() != null) {
                    File file = new File(Uri.parse(data.getDataString()).getPath());
                    try {
                        file = from(ac, Uri.parse(data.getDataString()));
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    FileItem fileItem = new FileItem();
                    fileItem.setTitle(file.getName());
                    fileItem.setRecentFile(false);
                    fileItem.setFolder(file.isDirectory());
                    fileItem.setPath(file.getPath());
                    fileItem.setStorage(false);
                    String fname = file.getName();
                    String[] sp = fname.split("\\.");
                    fileItem.setExtension(sp.length > 1 ? sp[sp.length - 1] : "?");
                    fileItem.setFileSize((int) file.length());
                    fileItem.setDescription(formatFileSize(file.length()));
                    Log.e(TAG, "3");
                    Gson gson = new Gson();
                    String json = gson.toJson(fileItem);
                    result.success(json);
                }
            } else {
                result.error("Not able to get the file", null, null);
            }
            return true;
        }
        return false;
    }
}
