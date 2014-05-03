/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package socof;

/**
 *
 * @author Carlos
 */
public class Possition {

    double axisX;
    double axisY;
    double axisZ;

    public Possition() {
    }

    public Possition(double axisX, double axisY, double axisZ) {
        this.axisX = axisX;
        this.axisY = axisY;
        this.axisZ = axisZ;
    }

    public double getAxisX() {
        return axisX;
    }

    public void setAxisX(double axisX) {
        this.axisX = axisX;
    }

    public double getAxisY() {
        return axisY;
    }

    public void setAxisY(double axisY) {
        this.axisY = axisY;
    }

    public double getAxisZ() {
        return axisZ;
    }

    public void setAxisZ(double axisZ) {
        this.axisZ = axisZ;
    }

    @Override
    public String toString() {
        return "Possition{" + "axisX=" + axisX + ", axisY=" + axisY + ", axisZ=" + axisZ + '}';
    }

}
