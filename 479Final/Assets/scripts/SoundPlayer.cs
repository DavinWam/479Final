using UnityEngine;

public class SoundPlayer : MonoBehaviour
{
    public AudioSource audioSource;
    
    public AudioClip[] audioClips;
    private int currentIndex = 0;

    void Start(){

        audioSource = GetComponent<AudioSource>();
    }

    // Method to play the next sound in the list
    public void PlayNextSound()
    {
        if (audioClips.Length == 0)
        {
            Debug.LogWarning("No audio clips assigned.");
            return;
        }

        // Play the current sound
        audioSource.clip = audioClips[currentIndex];
        audioSource.Play();

        // Move to the next sound, and wrap around if necessary
        currentIndex = (currentIndex + 1) % audioClips.Length;
    }
}
