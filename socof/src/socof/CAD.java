/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package socof;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Random;

/**
 * Collision avoidance and detection
 * 
 * @author Carlos
 */
public class CAD extends Thread{
    
    ArrayList<Car> carList;
    Car currentCar;
    double elapsedTime;

    public CAD(ArrayList<Car> carList, Car currentCar, double elapsedTime) {
        this.carList = carList;
        this.currentCar = currentCar;
        this.elapsedTime = elapsedTime;
    }
    
    public double calculateSpeed(Possition pInitial, Possition pFinal)
    {
        double axisXAux = Math.pow((pInitial.getAxisX()-pFinal.getAxisX()), 2);
        double axisYux = Math.pow((pInitial.getAxisY()-pFinal.getAxisY()),2);
        return Math.sqrt(axisXAux+axisYux);
    }
    
    public Possition calculateSpeedVector(Possition pInitial, Possition pFinal, double time)
    {
        Possition pos = new Possition();
        pos.setAxisX(pInitial.getAxisX() + time * (pFinal.getAxisX() - pInitial.getAxisX()));
        pos.setAxisY(pInitial.getAxisY() + time * (pFinal.getAxisY() - pInitial.getAxisY()));
        return pos;
    }
    
    public Possition calculatePossition(double time,Possition direction, Possition pInitial)
    {
        Possition pos = new Possition();
        pos.setAxisX(pInitial.getAxisX() + time * direction.getAxisX());
        pos.setAxisY(pInitial.getAxisY() + time * direction.getAxisY());
        return pos;
    }
      
    public double closestPointOfApproach(Possition w0, Possition vecSpeedCar1, Possition vecSpeedCar2)
    {
        // tc = -w0.(u - v) / (|u - v|)^2
        Possition negativeW0=escalarPossition(w0,-1);
        Possition aux =subtractPossition(vecSpeedCar1,vecSpeedCar2); //(u - v)
        
        double dividend= negativeW0.getAxisX() * aux.getAxisX() +  negativeW0.getAxisY() * aux.getAxisY();
        double divisor = Math.sqrt(Math.pow(aux.getAxisX(), 2) + Math.pow(aux.getAxisY(), 2));
        return dividend/divisor;
    }
    public boolean detectCollision(double elapsedTime, Car car1, Car car2)
    {
        //PROBLEMAS DE SYNCRONISMO - REVER!!!!!!!!!!!!!
        Possition car1InitialPossition = car1.getInitialPos();
        Possition car1Direction = car1.getDirection();
        Possition car1CurrentPossition = car1.getCurrentPos();
        
        Possition car2InitialPossition = car2.getInitialPos();
        Possition car2Direction = car2.getDirection();       
        Possition car2CurrentPossition = car2.getCurrentPos();
        
        Possition w0 =subtractPossition(car1InitialPossition,car2InitialPossition);
        //System.out.println("w0:" + w0.toString());    
        double timeOfPossibleCollision = closestPointOfApproach(w0,calculateSpeedVector(car1InitialPossition,car1CurrentPossition,elapsedTime),
                                                        calculateSpeedVector(car2InitialPossition,car2CurrentPossition,elapsedTime));
        //System.out.println("Collision:" + timeOfPossibleCollision/1000);    

        Possition car1FuturePossition = calculatePossition(timeOfPossibleCollision, car1InitialPossition, car1Direction);
        Possition car2FuturePossition = calculatePossition(timeOfPossibleCollision, car2InitialPossition, car2Direction);
        
        return detectCollision(car1FuturePossition,car2FuturePossition);
    }
    
    private boolean detectCollision(Possition car1FuturePossition, Possition car2FuturePossition) {
        
        if (car1FuturePossition.getAxisX() -2 > car2FuturePossition.getAxisX()){
            if (car1FuturePossition.getAxisX() +2 < car2FuturePossition.getAxisX()){
                if (car1FuturePossition.getAxisY() -2 > car2FuturePossition.getAxisY()){
                    if (car1FuturePossition.getAxisY() +2 < car2FuturePossition.getAxisY()){
                        System.out.println("detectCollision: acidente!");
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    public void avoidCollision(double elapsedTime, Car car1, Car car2)
    {
        Random rand=new Random();
        while (detectCollision(elapsedTime,car1,car2) == true)
        {
            int x=rand.nextInt(1); 
            if (x==1){              //abrandar x==1
                car1.setDirection(escalarPossition(car1.getDirection(),0.5));
            }else{                  //alterar direcção x==0
                car1.setDirection(addPossition(car1.getDirection(),new Possition(2.0, 2.0)));
            }
        }
    }
    public Possition subtractPossition(Possition vec1, Possition vec2)
    {
        Possition pos = new Possition();
        pos.setAxisX(vec1.getAxisX() - vec2.getAxisX());
        pos.setAxisY(vec1.getAxisY() - vec2.getAxisY());
        return pos;
    }
    
    public Possition addPossition(Possition vec1, Possition vec2)
    {
        Possition pos = new Possition();
        pos.setAxisX(vec1.getAxisX() + vec2.getAxisX());
        pos.setAxisY(vec1.getAxisY() + vec2.getAxisY());
        return pos;
    }
    
    public Possition multiplyPossition(Possition vec1, Possition vec2)
    {
        Possition pos = new Possition();
        pos.setAxisX(vec1.getAxisX() * vec2.getAxisX());
        pos.setAxisY(vec1.getAxisY() * vec2.getAxisY());
        return pos;
    }
    
    public Possition escalarPossition(Possition vec1, double escalar)
    {
        Possition pos = new Possition();
        pos.setAxisX(escalar * vec1.getAxisX());
        pos.setAxisY(escalar * vec1.getAxisY());
        return pos;
    }
    
    @Override
     public void run() {
         //System.out.println("CAD of: " + currentCar.getCarId());
         for (Car otherCar : carList) {
            if (detectCollision(elapsedTime,currentCar,otherCar)){
                avoidCollision(elapsedTime,currentCar,otherCar);
            }
        }
    }
    
}
