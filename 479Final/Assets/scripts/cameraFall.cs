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

        //Store start and end values
        Vector3 startPos = transform.position;
        Vector3 endPos = new Vector3(-1.56805336f, 2.01018572f, -12.04f);

        Quaternion startRot = transform.rotation;
        Quaternion endRot = Quaternion.Euler(0, 160.339005f, 9.45300007f);

        float slerpTimer = 0;

        //Rotate and move the camera to the proper place over 3 seconds
        while (slerpTimer < 1)
        {
            transform.position = Vector3.Lerp(startPos, endPos, slerpTimer);
            transform.rotation = Quaternion.Slerp(startRot, endRot, slerpTimer);

            slerpTimer += Time.deltaTime / 3;
            yield return null;
        }
        transform.position = endPos;
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
