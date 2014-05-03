/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package socof;

import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Carlos
 */
public class Car extends Thread{
    String id;
    Possition initialPos;
    Possition direction;
    Possition currentPos;
    double elapsedTime;
    ArrayList<Car> carList;

    public Car(String id, Possition initialPos, Possition direction, ArrayList<Car> carList) {
        this.id = id;
        this.initialPos = initialPos;
        this.currentPos = initialPos;
        this.direction = direction;
        this.elapsedTime = 0;
        this.carList = carList;
    }
        
    public Car(String id, Possition initialPos, Possition direction) {
        this.id = id;
        this.initialPos = initialPos;
        this.currentPos = initialPos;
        this.direction = direction;
        this.elapsedTime = 0;
    }
    
    public Car(String id) {
        this.id = id;
        this.initialPos = new Possition(0.0,0.0);
        this.currentPos = initialPos;
        this.direction = new Possition(2.0,3.0);
        this.elapsedTime = 0;
    }
    
    public ArrayList<Car> getCarList() {
        return carList;
    }

    public void setCarList(ArrayList<Car> carList) {
        this.carList = carList;
    }
    
    public double getElapsedTime() {
        return elapsedTime;
    }

    public void setElapsedTime(double elapsedTime) {
        this.elapsedTime = elapsedTime;
    }
    
    public Possition getDirection() {
        return direction;
    }

    public void setDirection(Possition direction) {
        this.direction = direction;
    }
    
    public void run() {
       double timeInterval = 1000.0; // mili segundos
       while (currentPos.axisX<1000 || currentPos.axisY<1000 || currentPos.axisX>0 || currentPos.axisY>0)
       {
           try {
               Thread.sleep((long)timeInterval);
               setElapsedTime(elapsedTime + timeInterval);
               currentPos=calculatePossition(elapsedTime/1000,initialPos,direction);
               CAD DetectorColision = new CAD(carList,this,getElapsedTime());
               DetectorColision.start();
                System.out.println(toString());
               //escrever na memoria partilhada
               //detectar colisão
               //ler da memoria partilhada ?
               //alterar direcção  ?
               //alterar velocidade ?
           } catch (InterruptedException ex) {
               Logger.getLogger(Car.class.getName()).log(Level.SEVERE, null, ex);
           }
       }
    }
    
    public Possition calculatePossition(double time, Possition pInitial, Possition direction)
    {
        Possition pos = new Possition();
        pos.setAxisX(pInitial.axisX + time * direction.axisX);
        pos.setAxisY(pInitial.axisY + time * direction.axisY);
        return pos;
    }

    @Override
    public String toString() {
        return "carro " + id + ": x=" + currentPos.axisX + " y="+ currentPos.axisY;
    }
    
}
