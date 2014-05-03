/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package socof;

import java.util.ArrayList;

/**
 *
 * @author Carlos
 */
public class Socof {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        //Car(String id, Possition initialPos, Possition direction, ArrayList<Car> carList)

        Car car1 = new Car("1", new Possition(0, 0,0.0), new Possition(2, 2,0.0));
        Car car2 = new Car("2", new Possition(0, 5,0.0), new Possition(2, 1,0.0));
        Car car3 = new Car("3",new Possition(5,0,0.0),new Possition(1,2,0.0));

        ArrayList ListaCar1 = new ArrayList<Car>();
        ArrayList ListaCar2 = new ArrayList<Car>();
        ArrayList ListaCar3 = new ArrayList<Car>();

        ListaCar1.add(car2);
        ListaCar1.add(car3);

        ListaCar2.add(car1);
        ListaCar2.add(car3);

        ListaCar3.add(car1);
        ListaCar3.add(car2);
        
        car1.setCarList(ListaCar1);
        car2.setCarList(ListaCar2);
        car3.setCarList(ListaCar3);

        car1.start();
        car2.start();
        car3.start();

    }
}
