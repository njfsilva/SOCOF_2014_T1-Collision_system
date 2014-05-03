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
        double axisXAux = Math.pow((pInitial.axisX-pFinal.axisX), 2);
        double axisYAux = Math.pow((pInitial.axisY-pFinal.axisY),2);
        return Math.sqrt(axisXAux+axisYAux);
    }
    
    public Possition calculateSpeedVector(Possition pInitial, Possition pFinal, double time)
    {
        Possition pos = new Possition();
        pos.setAxisX(pInitial.axisX + time * (pFinal.axisX - pInitial.axisX));
        pos.setAxisY(pInitial.axisY + time * (pFinal.axisY - pInitial.axisY));
        return pos;
    }
    
    public Possition calculatePossition(double time,Possition direction, Possition pInitial)
    {
        Possition pos = new Possition();
        pos.setAxisX(pInitial.axisX + time * direction.axisX);
        pos.setAxisY(pInitial.axisY + time * direction.axisY);
        return pos;
    }
      
    public double closestPointOfApproach(Possition w0, Possition vecSpeedCar1, Possition vecSpeedCar2)
    {
        // tc = -w0.(u - v) / (|u - v|)^2
        Possition negativeW0=escalarPossition(w0,-1);
        Possition aux =subtractPossition(vecSpeedCar1,vecSpeedCar2); //(u - v)
        
        double dividend= negativeW0.axisX * aux.axisX +  negativeW0.axisY * aux.axisY;
        double divisor = Math.pow(aux.axisX, 2) + Math.pow(aux.axisY, 2);
        return dividend/divisor;
    }
    public boolean detectCollision(double elapsedTime, Car car1, Car car2)
    {
        //PROBLEMAS DE SYNCRONISMO - REVER!!!!!!!!!!!!!
        Possition car1InitialPossition = car1.initialPos;
        Possition car1Direction = car1.direction;
        Possition car1CurrentPossition = car1.currentPos;
        
        Possition car2InitialPossition = car2.initialPos;
        Possition car2Direction = car2.direction;       
        Possition car2CurrentPossition = car2.currentPos;
        
        Possition w0 =subtractPossition(car1InitialPossition,car2InitialPossition);
        double timeOfPossibleCollision = closestPointOfApproach(w0,calculateSpeedVector(car1InitialPossition,car1CurrentPossition,elapsedTime),
                                                        calculateSpeedVector(car2InitialPossition,car2CurrentPossition,elapsedTime));
        
        Possition car1FuturePossition = calculatePossition(timeOfPossibleCollision, car1InitialPossition, car1Direction);
        Possition car2FuturePossition = calculatePossition(timeOfPossibleCollision, car2InitialPossition, car2Direction);
        
        return detectCollision(car1FuturePossition,car2FuturePossition);
    }
    
    private boolean detectCollision(Possition car1FuturePossition, Possition car2FuturePossition) {
        
        if (car1FuturePossition.axisX -2 > car2FuturePossition.axisX){
            if (car1FuturePossition.axisX +2 < car2FuturePossition.axisX){
                if (car1FuturePossition.axisY -2 > car2FuturePossition.axisY){
                    if (car1FuturePossition.axisY +2 < car2FuturePossition.axisY){
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
        pos.setAxisX(vec1.axisX - vec2.axisX);
        pos.setAxisY(vec1.axisY - vec2.axisY);
        return pos;
    }
    
    public Possition addPossition(Possition vec1, Possition vec2)
    {
        Possition pos = new Possition();
        pos.setAxisX(vec1.axisX + vec2.axisX);
        pos.setAxisY(vec1.axisY + vec2.axisY);
        return pos;
    }
    
    public Possition multiplyPossition(Possition vec1, Possition vec2)
    {
        Possition pos = new Possition();
        pos.setAxisX(vec1.axisX * vec2.axisX);
        pos.setAxisY(vec1.axisY * vec2.axisY);
        return pos;
    }
    
    public Possition escalarPossition(Possition vec1, double escalar)
    {
        Possition pos = new Possition();
        pos.setAxisX(escalar * vec1.axisX);
        pos.setAxisY(escalar * vec1.axisY);
        return pos;
    }
    
     public void run() {
        for(Iterator<Car> i = carList.iterator(); i.hasNext(); ) {
            Car otherCar = i.next();
            //double elapsedTime, Car car1, Car car2
            if (detectCollision(elapsedTime,currentCar,otherCar)){
                System.out.println("run: current car: "+ currentCar.id);
                avoidCollision(elapsedTime,currentCar,otherCar);
            }
        }
    }
    
}
