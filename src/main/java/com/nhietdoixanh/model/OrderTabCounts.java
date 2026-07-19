package com.nhietdoixanh.model;

/** Số lượng đơn hàng theo từng tab vòng đời trên trang admin /admin/don-hang. */
public class OrderTabCounts {
    private int all;
    private int pending;
    private int confirmed;
    private int shipping;
    private int awaitingConfirm;
    private int completed;

    public int getAll() { return all; }
    public void setAll(int all) { this.all = all; }

    public int getPending() { return pending; }
    public void setPending(int pending) { this.pending = pending; }

    public int getConfirmed() { return confirmed; }
    public void setConfirmed(int confirmed) { this.confirmed = confirmed; }

    public int getShipping() { return shipping; }
    public void setShipping(int shipping) { this.shipping = shipping; }

    public int getAwaitingConfirm() { return awaitingConfirm; }
    public void setAwaitingConfirm(int awaitingConfirm) { this.awaitingConfirm = awaitingConfirm; }

    public int getCompleted() { return completed; }
    public void setCompleted(int completed) { this.completed = completed; }
}
