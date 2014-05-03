/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package socof;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Random;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Collision avoidance and detection
 *
 * @author Carlos
 */
public class CAD extends Thread {

    ArrayList<Car> carList;
    Car currentCar;
    //double elapsedTime;

    public CAD(ArrayList<Car> carList, Car currentCar) {
        this.carList = carList;
        this.currentCar = currentCar;
    }

    public double calculateSpeed(Possition pInitial, Possition pFinal) {
        double axisXAux = Math.pow((pInitial.getAxisX() - pFinal.getAxisX()), 2);
        double axisYAux = Math.pow((pInitial.getAxisY() - pFinal.getAxisY()), 2);
        double axisZAux = Math.pow((pInitial.getAxisZ() - pFinal.getAxisZ()), 2);
        return Math.sqrt(axisXAux + axisYAux + axisZAux);
    }

    public Possition calculateSpeedVector(Possition pInitial, Possition pFinal, double time) {
        Possition pos = new Possition();
        pos.setAxisX(pInitial.getAxisX() + time * (pFinal.getAxisX() - pInitial.getAxisX()));
        pos.setAxisY(pInitial.getAxisY() + time * (pFinal.getAxisY() - pInitial.getAxisY()));
        pos.setAxisZ(pInitial.getAxisZ() + time * (pFinal.getAxisZ() - pInitial.getAxisZ()));
        return pos;
    }

    public Possition calculatePossition(double time, Possition pInitial, Possition direction) {
        Possition pos = new Possition();
        pos.setAxisX(pInitial.getAxisX() + time * direction.getAxisX());
        pos.setAxisY(pInitial.getAxisY() + time * direction.getAxisY());
        pos.setAxisZ(pInitial.getAxisZ() + time * direction.getAxisZ());
        return pos;
    }

    public double closestPointOfApproach(Possition w0, Possition vecSpeedCar1, Possition vecSpeedCar2) {
        // tc = -w0.(u - v) / (|u - v|)^2
        Possition negativeW0 = escalarPossition(w0, -1);
        Possition aux = subtractPossition(vecSpeedCar1, vecSpeedCar2); //(u - v)

        double dividend = negativeW0.getAxisX() * aux.getAxisX() + negativeW0.getAxisY() * aux.getAxisY() + negativeW0.getAxisZ() * aux.getAxisZ();
        double divisor = Math.sqrt(Math.pow(aux.getAxisX(), 2) + Math.pow(aux.getAxisY(), 2) + Math.pow(aux.getAxisZ(), 2));
        return dividend / divisor;
    }

    public boolean detectCollision(Car car1, Car car2) {
        //PROBLEMAS DE SYNCRONISMO - REVER!!!!!!!!!!!!!
        Possition car1InitialPossition = car1.getInitialPos();
        Possition car1Direction = car1.getDirection();
        Possition car1CurrentPossition = car1.getCurrentPos();

        Possition car2InitialPossition = car2.getInitialPos();
        Possition car2Direction = car2.getDirection();
        Possition car2CurrentPossition = car2.getCurrentPos();

        Possition w0 = subtractPossition(car1InitialPossition, car2InitialPossition);
        //System.out.println("w0:" + w0.toString());    
        double timeOfPossibleCollision = closestPointOfApproach(w0, calculateSpeedVector(car1InitialPossition, car1CurrentPossition, car1.getTime()),
                calculateSpeedVector(car2InitialPossition, car2CurrentPossition, car2.getTime()));

        Possition car1FuturePossition = calculatePossition(timeOfPossibleCollision, car1InitialPossition, car1Direction);
        Possition car2FuturePossition = calculatePossition(timeOfPossibleCollision, car2InitialPossition, car2Direction);

        return detectCollision(car1FuturePossition, car2FuturePossition);
    }

    private boolean detectCollision(Possition car1FuturePossition, Possition car2FuturePossition) {

        if (car1FuturePossition.getAxisX() <= 0 && car1FuturePossition.getAxisX() > 1000 && car1FuturePossition.getAxisY() <= 0 && car1FuturePossition.getAxisY() > 1000) {
            return true;
        }
        if (car1FuturePossition.getAxisX() - 2 <= car2FuturePossition.getAxisX()) {
            if (car1FuturePossition.getAxisX() + 2 >= car2FuturePossition.getAxisX()) {
                if (car1FuturePossition.getAxisY() - 2 <= car2FuturePossition.getAxisY()) {
                    if (car1FuturePossition.getAxisY() + 2 >= car2FuturePossition.getAxisY()) {
                        if (car1FuturePossition.getAxisZ() - 2 <= car2FuturePossition.getAxisZ()) {
                            if (car1FuturePossition.getAxisZ() + 2 >= car2FuturePossition.getAxisZ()) {
                                return true;
                            }
                        }
                    }
                }
            }
        }
        return false;
    }

    public void avoidCollision(Car car1) {

        Random rand = new Random();
        switch (rand.nextInt(10)) {
            case 1:             //abrandar
                car1.setInitialPos(car1.getCurrentPos());
                car1.setTime(0);
                car1.setDirection(escalarPossition(car1.getDirection(), 0.5));
                System.out.println("Alterar pos car: " + car1.getCarId() + " new direction: " + car1.getDirection().toString());

                break;          //alterar direcção
            case 2:
                car1.setInitialPos(car1.getCurrentPos());
                car1.setTime(0);
                car1.setDirection(addPossition(car1.getDirection(), new Possition(3.0, 0.0, 0.0)));
                System.out.println("Alterar pos car: " + car1.getCarId() + " new direction: " + car1.getDirection().toString());

                break;
            case 3:
                car1.setInitialPos(car1.getCurrentPos());
                car1.setTime(0);
                car1.setDirection(addPossition(car1.getDirection(), new Possition(0.0, 3.0, 0.0)));
                System.out.println("Alterar pos car: " + car1.getCarId() + " new direction: " + car1.getDirection().toString());

                break;
            case 4:
                car1.setInitialPos(car1.getCurrentPos());
                car1.setTime(0);
                car1.setDirection(subtractPossition(car1.getDirection(), new Possition(3.0, 3.0, 0.0)));
                System.out.println("Alterar pos car: " + car1.getCarId() + " new direction: " + car1.getDirection().toString());

                break;
            case 5:
                car1.setInitialPos(car1.getCurrentPos());
                car1.setTime(0);
                car1.setDirection(subtractPossition(car1.getDirection(), new Possition(0.0, 3.0, 0.0)));
                System.out.println("Alterar pos car: " + car1.getCarId() + " new direction: " + car1.getDirection().toString());

                break;
            case 6:
                car1.setInitialPos(car1.getCurrentPos());
                car1.setTime(0);
                car1.setDirection(subtractPossition(car1.getDirection(), new Possition(3.0, 0.0, 0.0)));
                System.out.println("Alterar pos car: " + car1.getCarId() + " new direction: " + car1.getDirection().toString());

                break;
            case 7:
                car1.setInitialPos(car1.getCurrentPos());
                car1.setTime(0);
                car1.setDirection(addPossition(car1.getDirection(), new Possition(3.0, 3.0, 0.0)));
                System.out.println("Alterar pos car: " + car1.getCarId() + " new direction: " + car1.getDirection().toString());

                break;
            case 8:
                car1.setInitialPos(car1.getCurrentPos());
                car1.setTime(0);
                car1.setDirection(escalarPossition(car1.getDirection(), 0.8));
                System.out.println("Alterar pos car: " + car1.getCarId() + " new direction: " + car1.getDirection().toString());

                break;
            case 9:
                car1.setInitialPos(car1.getCurrentPos());
                car1.setTime(0);
                car1.setDirection(escalarPossition(car1.getDirection(), -0.5));
                System.out.println("Alterar pos car: " + car1.getCarId() + " new direction: " + car1.getDirection().toString());

                break;
            case 10:
                car1.setInitialPos(car1.getCurrentPos());
                car1.setTime(0);
                car1.setDirection(escalarPossition(car1.getDirection(), 2));
                System.out.println("Alterar pos car: " + car1.getCarId() + " new direction: " + car1.getDirection().toString());

                break;
        }
    }

    private boolean colisionWithLimiter(Car currentCar) {

        Possition carFuturePossition = calculatePossition(currentCar.getTime() + 1, currentCar.getInitialPos(), currentCar.getDirection());
        if (carFuturePossition.getAxisX() <= 0) {
            if (carFuturePossition.getAxisX() >= 1000) {
                if (carFuturePossition.getAxisY() <= 0) {
                    if (carFuturePossition.getAxisY() >= 1000) {
                        return true;
                    }
                }
            }
        }
        return false;
        //        return carFuturePossition.getAxisX() <= 0 && carFuturePossition.getAxisX() > 1000 && carFuturePossition.getAxisY() <= 0 && carFuturePossition.getAxisY() > 1000;

    }

    public Possition subtractPossition(Possition vec1, Possition vec2) {
        Possition pos = new Possition();
        pos.setAxisX(vec1.getAxisX() - vec2.getAxisX());
        pos.setAxisY(vec1.getAxisY() - vec2.getAxisY());
        pos.setAxisZ(vec1.getAxisZ() - vec2.getAxisZ());
        return pos;
    }

    public Possition addPossition(Possition vec1, Possition vec2) {
        Possition pos = new Possition();
        pos.setAxisX(vec1.getAxisX() + vec2.getAxisX());
        pos.setAxisY(vec1.getAxisY() + vec2.getAxisY());
        pos.setAxisZ(vec1.getAxisZ() + vec2.getAxisZ());
        return pos;
    }

    public Possition multiplyPossition(Possition vec1, Possition vec2) {
        Possition pos = new Possition();
        pos.setAxisX(vec1.getAxisX() * vec2.getAxisX());
        pos.setAxisY(vec1.getAxisY() * vec2.getAxisY());
        pos.setAxisZ(vec1.getAxisZ() * vec2.getAxisZ());
        return pos;
    }

    public Possition escalarPossition(Possition vec1, double escalar) {
        Possition pos = new Possition();
        pos.setAxisX(escalar * vec1.getAxisX());
        pos.setAxisY(escalar * vec1.getAxisY());
        pos.setAxisZ(escalar * vec1.getAxisZ());
        return pos;
    }

    @Override
    public void run() {
        //System.out.println("CAD of: " + currentCar.getCarId());
        for (Car otherCar : carList) {
            if (detectCollision(currentCar.getCurrentPos(), otherCar.getCurrentPos())) {
                //throw new Accident("acidente! Entre: " + currentCar.getCarId() + " e " + otherCar.getCarId() + "; tempo:" + elapsedTime / 1000 + "; currentCar: " + currentCar.getCurrentPos().toString() + " - othercar: " + otherCar.getCurrentPos().toString());
                System.out.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!acidente! Entre: " + currentCar.getCarId() + " e " + otherCar.getCarId() + "; currentCar: " + currentCar.getCurrentPos().toString() + " - othercar: " + otherCar.getCurrentPos().toString());
            }
        }
        boolean detectedCollision = false;
        while (detectedCollision == false) {
            detectedCollision = false;
            for (Car otherCar : carList) {
                while (detectCollision(currentCar, otherCar) == true) {
                    System.out.println("possivel acidente ente: " + currentCar.getCarId() + " e " + otherCar.getCarId() + "; currentCar: " + currentCar.getCurrentPos().toString() + " - othercar: " + otherCar.getCurrentPos().toString());
                    avoidCollision(currentCar);
                    detectedCollision = true;
                }
            }
            if (colisionWithLimiter(currentCar)) {
             //   System.out.println("possivel inpacto com os limites da area");
                //avoidCollision(currentCar);
                //   detectedCollision = true;
            }
        }
        //System.out.println("Collision Avoided!");

    }

}
