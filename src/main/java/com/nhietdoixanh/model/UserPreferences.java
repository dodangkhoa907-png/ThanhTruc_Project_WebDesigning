package com.nhietdoixanh.model;

import java.util.Date;

/** Sở thích khách hàng — ánh xạ bảng UserPreferences (1-1 với Users). */
public class UserPreferences {
    private int preferenceId;
    private int userId;
    private String plantInterests;
    private String decorStyles;
    private String spaceType;
    private String careLevel;
    private String notes;
    private Date updatedAt;

    public UserPreferences() {}

    public int getPreferenceId() { return preferenceId; }
    public void setPreferenceId(int preferenceId) { this.preferenceId = preferenceId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getPlantInterests() { return plantInterests; }
    public void setPlantInterests(String plantInterests) { this.plantInterests = plantInterests; }

    public String getDecorStyles() { return decorStyles; }
    public void setDecorStyles(String decorStyles) { this.decorStyles = decorStyles; }

    public String getSpaceType() { return spaceType; }
    public void setSpaceType(String spaceType) { this.spaceType = spaceType; }

    public String getCareLevel() { return careLevel; }
    public void setCareLevel(String careLevel) { this.careLevel = careLevel; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}
