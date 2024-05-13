using UnityEngine;

public class CameraRotation : MonoBehaviour
{
    public float rotationSpeed = 3f;
    public float maxVerticalAngle = 85f;
    public float minVerticalAngle = -85f;

    private float verticalRotation = 0f;  // Separate tracking of vertical rotation

    void Start()
    {
        // Hide and lock the cursor
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }

    void Update()
    {
        // Get mouse input
        float mouseX = Input.GetAxis("Mouse X") * rotationSpeed;
        float mouseY = Input.GetAxis("Mouse Y") * rotationSpeed;

        // Horizontal rotation
        transform.Rotate(Vector3.up, mouseX, Space.World);

        // Calculate new vertical rotation
        verticalRotation -= mouseY;
        verticalRotation = Mathf.Clamp(verticalRotation, minVerticalAngle, maxVerticalAngle);

        // Apply vertical rotation to the camera
        // Ensure to use local rotation to avoid global axis misalignments
        Quaternion verticalQuaternion = Quaternion.Euler(verticalRotation, 0, 0);
        transform.localRotation = Quaternion.Euler(verticalRotation, transform.localEulerAngles.y, 0);
    }
}
