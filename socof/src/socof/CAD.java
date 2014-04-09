/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package socof;

/**
 * Collision avoidance and detection
 * 
 * @author Carlos
 */
public class CAD extends Thread{
    
    
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
    
    public Possition calculatePossition(double time,Possition speed, Possition pInitial)
    {
        Possition pos = new Possition();
        pos.setAxisX(pInitial.axisX + time * speed.axisX);
        pos.setAxisY(pInitial.axisY + time * speed.axisY);
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
        
    }
    
}
