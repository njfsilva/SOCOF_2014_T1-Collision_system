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
    double time;
    ArrayList<Car> carList;

    public Car(String id, Possition initialPos, Possition direction, ArrayList<Car> carList) {
        this.id = id;
        this.initialPos = initialPos;
        this.currentPos = initialPos;
        this.direction = direction;
        this.elapsedTime = 0;
        this.time = 0;
        this.carList = carList;
    }
        
    public Car(String id, Possition initialPos, Possition direction) {
        this.id = id;
        this.initialPos = initialPos;
        this.currentPos = initialPos;
        this.direction = direction;
        this.elapsedTime = 0;
                this.time = 0;

    }
    
    public Car(String id) {
        this.id = id;
        this.initialPos = new Possition(0.0,0.0,0.0);
        this.currentPos = initialPos;
        this.direction = new Possition(2.0,3.0,0.0);
        this.elapsedTime = 0;
                this.time = 0;

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
    
    public synchronized Possition getDirection() {
        return direction;
    }

    public synchronized void setDirection(Possition direction) {
        this.direction = direction;
    }

    public void setId(String id) {
        this.id = id;
    }

    public synchronized Possition getInitialPos() {
        return initialPos;
    }

    public synchronized void setInitialPos(Possition initialPos) {
        this.initialPos = initialPos;
    }

    public Possition getCurrentPos() {
        return currentPos;
    }

    public synchronized void setCurrentPos(Possition currentPos) {
        this.currentPos = currentPos;
    }

    public String getCarId() {
        return id;
    }

    public synchronized double getTime() {
        return time;
    }

    public synchronized void setTime(double time) {
        this.time = time;
    }
    
    public void run() {
       double timeInterval = 1000.0; // mili segundos
       while (currentPos.axisX<1000 && currentPos.axisY<1000 && currentPos.axisX>=0 && currentPos.axisY>=0)
       {
           try {
               Thread.sleep((long)timeInterval);
               setElapsedTime(getElapsedTime() + timeInterval);
               setTime(getTime() + timeInterval);
               setCurrentPos(calculatePossition(getTime()/1000,getInitialPos(),getDirection()));
               CAD DetectorColision = new CAD(carList,this);
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
        System.out.println("Carro: "+ id + " saiu fora do area.");
    }
    
    public Possition calculatePossition(double time, Possition pInitial, Possition direction)
    {
        Possition pos = new Possition();
        pos.setAxisX(pInitial.getAxisX() + time * direction.getAxisX());
        pos.setAxisY(pInitial.getAxisY() + time * direction.getAxisY());
        pos.setAxisZ(pInitial.getAxisZ() + time * direction.getAxisZ());
        return pos;
    }

    @Override
    public String toString() {
        return "carro " + id + ": x=" + currentPos.axisX + " y="+ currentPos.axisY + "; ElapsedTime: "+(elapsedTime/1000);
    }
    
}
