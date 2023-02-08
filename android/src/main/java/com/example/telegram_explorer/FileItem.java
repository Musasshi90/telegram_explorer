package com.example.telegram_explorer;

import java.io.Serializable;

public class FileItem implements Serializable {
    private String title;
    private String description;
    private String path;
    private boolean isFolder;
    private String extension;
    private boolean isRecentFile;
    private boolean isStorage;
    private int fileSize;

    public int getFileSize() {
        return fileSize;
    }

    public void setFileSize(int fileSize) {
        this.fileSize = fileSize;
    }

    public boolean isStorage() {
        return isStorage;
    }

    public void setStorage(boolean storage) {
        isStorage = storage;
    }

    public boolean isRecentFile() {
        return isRecentFile;
    }

    public void setRecentFile(boolean recentFile) {
        isRecentFile = recentFile;
    }

    public String getExtension() {
        return extension;
    }

    public void setExtension(String extension) {
        this.extension = extension;
    }

    public boolean isFolder() {
        return isFolder;
    }

    public void setFolder(boolean folder) {
        isFolder = folder;
    }


    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }
}
