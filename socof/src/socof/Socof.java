/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package socof;

import java.util.ArrayList;
import java.util.Random;

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
    	
    	int numberOfCars = 10;
    	ArrayList<Car> listOfCars = new ArrayList<Car>();
    	
    	for(int i=0;i<numberOfCars;i++){
    		
    		Random random = new Random();
    		
    		listOfCars.add(
    				new Car(
    						String.format("%s", i+1),
    						new Possition(random.nextInt(1001),random.nextInt(1001),random.nextInt(1001)),
    						new Possition(random.nextInt(21),random.nextInt(21),random.nextInt(21))
						)
    			);
    	}
    	
    	for(Car car : listOfCars){
    		@SuppressWarnings("unchecked")
			ArrayList<Car> listOfOtherCars = (ArrayList<Car>) listOfCars.clone();
    		listOfOtherCars.remove(car);
    		car.setCarList(listOfOtherCars);
    		
    		car.start();
    	}
    	
		
    	
    	/*
        Car car1 = new Car("1", new Possition(0,0,0), new Possition(2,2,0));
        Car car2 = new Car("2", new Possition(0,5,0), new Possition(2,1,0));
        Car car3 = new Car("3",new Possition(5,0,0),new Possition(1,2,0));

        ArrayList<Car> ListaCar1 = new ArrayList<Car>();
        ArrayList<Car> ListaCar2 = new ArrayList<Car>();
        ArrayList<Car> ListaCar3 = new ArrayList<Car>();

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
        */

    }
}
