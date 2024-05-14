using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class cameraFall : MonoBehaviour
{
    // Start is called before the first frame update
    IEnumerator Start()
    {
        yield return new WaitForSeconds(5f);
        StartCoroutine(CamFall());
    }

    // Cam fall script
    public IEnumerator CamFall()
    {
        //Disable the look script
        GetComponent<CameraRotation>().enabled = false;

        Quaternion startRot = transform.rotation;
        Quaternion endRot = Quaternion.Euler(0, 160.339005f, 9.45300007f);

        float slerpTimer = 0;

        //Rotate and move the camera to the proper place over 3 seconds
        while (slerpTimer < 1)
        {
            transform.rotation = Quaternion.Slerp(startRot, endRot, slerpTimer);

            slerpTimer += Time.deltaTime / 3;
            yield return null;
        }
        transform.rotation = endRot;

        //Make camera shake as looking at creature
        slerpTimer = 0;
        while (slerpTimer < 1)
        {
            transform.Rotate(Random.Range(-slerpTimer, slerpTimer), Random.Range(-slerpTimer, slerpTimer), Random.Range(-slerpTimer, slerpTimer));

            slerpTimer += Time.deltaTime;
            yield return null;
        }
        GetComponent<Animation>().Play();
    }

}
