//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "76c402bfe58d0417eea338e148b7775b"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        //bepaald hoe nauwkeurig de locatie moet zijn
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //toestemming vragen aan user voor gebruik van locatie
        locationManager.requestWhenInUseAuthorization()
        
        //locationManager start met het zoeken van GPS locatie
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters : [String : String]) {
        
        //HTTP request aan de openweatherapp api, met een get method en de lon, lat en app_id. Dit gebeurt op de achtergrond, maar geeft uiteindelijk een response
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            //als de response er is dan kan er worden gecheckt of het valide is
            if response.result.isSuccess{
                print("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                //self zorgt ervoor dat er wordt gekeken naar de hele class
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON) {
        //variabele kijkt naar het gehele json file en haalt main eruit en vervolgens temp en zet het om naar een double
        if let tempResult = json["main"]["temp"].double {
        
        //haalt tempResult op, -273.15 zodat het wordt omgezet naar celsius
        weatherDataModel.temperature = Int(tempResult - 273.15)
        
        //haalt de naam van de stad op en zet het om naar een string
        weatherDataModel.city = json["name"].stringValue
        
        //haalt het weer op en zet het om naar een int
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        //Uit het model wordt de juiste case gehaald aan de hand van de condition id die hierboven wordt opgehaald
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    //Deze functie wordt aangeroepen als de locationManager de locatie heeft gevonden
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //De meest recente locatie wordt opgehaald uit de array
        let location = locations[locations.count - 1]
        
        //checkt of er geen invalide data wordt doorgegeven
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            //hierdoor zie je de data maar één keer als het tussendoor gestopt is
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            //Variabele worden gecreerd, zodat ze kunnen worden doorgegeven
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            //Variabele worden in één variabele samengevat door middel van een dictionaries
            let params = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters : params)
        }
    }
    
    //Als de locationManager geen locatie kan vinden
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredNewCityName(city : String){
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }

    
    //Write the PrepareForSegue Method here
    //Deze functie wordt getriggerd als er wordt geklikt op de seque
    override func prepare(for seque: UIStoryboardSegue, sender: Any?){
        if seque.identifier == "changeCityName" {
            let destinationVC = seque.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


