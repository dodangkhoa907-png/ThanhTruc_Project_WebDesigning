package com.nhietdoixanh.model;

import java.math.BigDecimal;
import java.util.Date;

public class UserAddress {
    private int addressId;
    private int userId;
    private String label;
    private String recipientName;
    private String phone;
    private String street;
    private boolean isDefault;
    private Date createdAt;

    // Bổ sung — địa chỉ chi tiết + tọa độ giao hàng (xem migration_ecommerce_account_v3.sql)
    private String provinceCity;
    private String district;
    private String ward;
    private String houseNumberStreet;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private Date updatedAt;

    public UserAddress() {}

    public int getAddressId() { return addressId; }
    public void setAddressId(int addressId) { this.addressId = addressId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }

    public String getRecipientName() { return recipientName; }
    public void setRecipientName(String recipientName) { this.recipientName = recipientName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getStreet() { return street; }
    public void setStreet(String street) { this.street = street; }

    public boolean isDefault() { return isDefault; }
    public void setDefault(boolean isDefault) { this.isDefault = isDefault; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getProvinceCity() { return provinceCity; }
    public void setProvinceCity(String provinceCity) { this.provinceCity = provinceCity; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public String getHouseNumberStreet() { return houseNumberStreet; }
    public void setHouseNumberStreet(String houseNumberStreet) { this.houseNumberStreet = houseNumberStreet; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}
