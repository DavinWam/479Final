using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ContextSetting : MonoBehaviour
{
    public AudioSource carCrashSound, carDoor, leafRun, leafCrunch, leafCrunch2;
    // Start is called before the first frame update
    IEnumerator Start()
    {
        yield return new WaitForSeconds(1.5f);
        carCrashSound.Play();
        yield return new WaitForSeconds(21f);
        carDoor.Play();
        yield return new WaitForSeconds(2f);
        leafCrunch2.Play();
        yield return new WaitForSeconds(2f);
        leafRun.Play();
        yield return new WaitForSeconds(6f);
        leafCrunch.Play();
        yield return new WaitForSeconds(3f);

        SceneManager.LoadScene(0);
    }
}
