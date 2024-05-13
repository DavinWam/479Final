using UnityEngine;
using TMPro; // Include the TextMeshPro namespace

public class Timer : MonoBehaviour
{
    public TMP_Text timerText; // Reference to the TextMeshPro text component
    public int startHours = 0; // Start hours input from the editor
    public int startMinutes = 0; // Start minutes input from the editor
    public int startSeconds = 0; // Start seconds input from the editor

    private float elapsedTime = 0f; // Time in seconds since the timer started

    void Start()
    {
        ResetTimer(); // Initialize the timer with the start time
    }

    void Update()
    {
        elapsedTime += Time.deltaTime; // Increment the time by the time elapsed since last frame
        UpdateTimerDisplay(); // Update the timer display continuously
    }

    void ResetTimer()
    {
        // Calculate the start time in seconds from hours, minutes, and seconds
        float startTimeInSeconds = startHours * 3600 + startMinutes * 60 + startSeconds;
        elapsedTime = startTimeInSeconds; // Set elapsed time to the start time
        UpdateTimerDisplay(); // Update the timer display immediately
    }

    void UpdateTimerDisplay()
    {
        // Convert elapsed time back into hours, minutes, and seconds
        int hours = (int)(elapsedTime / 3600);
        int minutes = (int)((elapsedTime % 3600) / 60);
        int seconds = (int)(elapsedTime % 60);

        timerText.text = string.Format("{0:00}:{1:00}:{2:00}", hours, minutes, seconds);
    }
}
