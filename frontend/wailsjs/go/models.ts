export namespace models {
	
	export class Alarm {
	    id: number;
	    prayer: string;
	    offsetMinutes: number;
	    label: string;
	    soundPath: string;
	    isActive: boolean;
	    repeatDays: number[];
	    vibrationEnabled: boolean;
	    createdAt: number;
	    updatedAt: number;
	
	    static createFrom(source: any = {}) {
	        return new Alarm(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.prayer = source["prayer"];
	        this.offsetMinutes = source["offsetMinutes"];
	        this.label = source["label"];
	        this.soundPath = source["soundPath"];
	        this.isActive = source["isActive"];
	        this.repeatDays = source["repeatDays"];
	        this.vibrationEnabled = source["vibrationEnabled"];
	        this.createdAt = source["createdAt"];
	        this.updatedAt = source["updatedAt"];
	    }
	}
	export class AppSettings {
	    calculationMethod: string;
	    juristicMethod: string;
	    audioTheme: string;
	    is24HourFormat: boolean;
	    enableNotifications: boolean;
	    enableVibration: boolean;
	    theme: string;
	    language: string;
	
	    static createFrom(source: any = {}) {
	        return new AppSettings(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.calculationMethod = source["calculationMethod"];
	        this.juristicMethod = source["juristicMethod"];
	        this.audioTheme = source["audioTheme"];
	        this.is24HourFormat = source["is24HourFormat"];
	        this.enableNotifications = source["enableNotifications"];
	        this.enableVibration = source["enableVibration"];
	        this.theme = source["theme"];
	        this.language = source["language"];
	    }
	}
	export class Location {
	    id: number;
	    name: string;
	    country: string;
	    latitude: number;
	    longitude: number;
	    timezone: string;
	    isCurrent: boolean;
	    createdAt: number;
	
	    static createFrom(source: any = {}) {
	        return new Location(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.id = source["id"];
	        this.name = source["name"];
	        this.country = source["country"];
	        this.latitude = source["latitude"];
	        this.longitude = source["longitude"];
	        this.timezone = source["timezone"];
	        this.isCurrent = source["isCurrent"];
	        this.createdAt = source["createdAt"];
	    }
	}
	export class PrayerTimes {
	    fajr: string;
	    dhuhr: string;
	    asr: string;
	    maghrib: string;
	    isha: string;
	
	    static createFrom(source: any = {}) {
	        return new PrayerTimes(source);
	    }
	
	    constructor(source: any = {}) {
	        if ('string' === typeof source) source = JSON.parse(source);
	        this.fajr = source["fajr"];
	        this.dhuhr = source["dhuhr"];
	        this.asr = source["asr"];
	        this.maghrib = source["maghrib"];
	        this.isha = source["isha"];
	    }
	}

}

