/**
 * Sound assets index
 * This file provides a central place to import and export all sound assets
 * used in the application.
 */

export const sounds = {
    adhan_makkah: require('./adhan_makkah.mp3'),
    adhan_madina: require('./adhan_madina.mp3'),
    adhan_mishari: require('./adhan_mishari.mp3'),
    takbir_simple: require('./takbir_simple.mp3'),
};

export type SoundKey = keyof typeof sounds;
