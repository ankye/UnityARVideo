using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.SceneManagement;
using Vuforia;

public class TransparentWindow : MonoBehaviour
{
    [SerializeField]

    public GameObject[] character;

    public AnimCtr ac;

    private ArrayList pArr;
    private ArrayList rArr;
    public Camera m_screenShotCamera;

    float x;
    float y;
    float z;
    float scale;
    float rx;
    float ry;

    float lx;
    float ly;
    float lz;

    public Light light;

    private struct MARGINS
    {
       
    }

    // Define function signatures to import from Windows APIs

    [DllImport("user32.dll")]
    private static extern IntPtr GetActiveWindow();

    [DllImport("user32.dll")]
    private static extern int SetWindowLong(IntPtr hWnd, int nIndex, uint dwNewLong);

    [DllImport("Dwmapi.dll")]
    private static extern uint DwmExtendFrameIntoClientArea(IntPtr hWnd, ref MARGINS margins);

    [DllImport("__Internal")]
    private static extern void unityToIOS(string str);

    // Definitions of window styles
    //const int GWL_STYLE = -16;
    //const uint WS_POPUP = 0x80000000;
    //const uint WS_VISIBLE = 0x10000000;

    void Start()
    {
#if !UNITY_EDITOR && UNITY_STANDALONE_WIN
        var margins = new MARGINS() { cxLeftWidth = -1 };
 
        // Get a handle to the window
        var hwnd = GetActiveWindow();
 
        // Set properties of the window
        // See: https://msdn.microsoft.com/en-us/library/windows/desktop/ms633591%28v=vs.85%29.aspx
        SetWindowLong(hwnd, GWL_STYLE, WS_POPUP | WS_VISIBLE);
 
        // Extend the window into the client area
        //See: https://msdn.microsoft.com/en-us/library/windows/desktop/aa969512%28v=vs.85%29.aspx 
        DwmExtendFrameIntoClientArea(hwnd, ref margins);
#endif


        resetPosition();

       // iosToUnity("C,3,5");
    }

    void resetPosition()
    {
        pArr = new ArrayList(character.Length);
        rArr = new ArrayList(character.Length);

        foreach (GameObject a in character)
        {
            Vector3 p = new Vector3(a.transform.position.x, a.transform.position.y, a.transform.position.z);
            Vector3 r = new Vector3(a.transform.rotation.x, a.transform.rotation.y, a.transform.rotation.z);
            Debug.Log("p " + p.x + " " + p.y + " " + p.z);
            Debug.Log("r " + r.x + " " + r.y + " " + r.z);

            pArr.Add(p);
            rArr.Add(r);
        }
        x = 0;
        y = 0;
        z = 0;
        scale = 3;
        rx = 0;
        ry = 0;
        lx = 45;
        ly = 90;
        lz = 90;
    }

    public string savePhoto()
    {
    

        // Create renderTexture & Render
        RenderTexture rt = new RenderTexture(Screen.width, Screen.height, 24);
        
        m_screenShotCamera.targetTexture = rt;          // camera renderTarget => renderTexture
        m_screenShotCamera.Render();
        m_screenShotCamera.targetTexture = null;        // camera renderTarget => Screen

        // Create Texture2D & Save texture as png file
        RenderTexture.active = rt;      // ReadPixel target = renderTextrue

        Texture2D screenShot = new Texture2D(Screen.width, Screen.height, TextureFormat.RGB24, false);
        screenShot.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);

        RenderTexture.active = null; // JC: added to avoid errors
        Destroy(rt);
        byte[] screenShotBytes = screenShot.EncodeToPNG();
        System.DateTime now = System.DateTime.Now;
        string timeStr = now.Year.ToString() + now.Month.ToString() + now.Day.ToString() +
            now.Hour.ToString() + now.Minute.ToString() + now.Second.ToString();
        string path = Application.persistentDataPath + "/" + timeStr + ".jpg";
        Debug.Log(path);
        File.WriteAllBytes(path, screenShotBytes);

        return path;

    }
    // Pass the output of the camera to the custom material
    // for chroma replacement
    void iosToUnity(string str)
    {
        char[] separator = { ',', ';' };
        string[] param = str.Split(separator);
        Debug.Log("iosToUnity" + str);
        string name = param[0];
        int type = Convert.ToInt32(param[1]);
        float value;
        if (float.TryParse(param[2], out value))
        {
            if (name == "L")
            {
                changeLight(type, value);
            }
            else if (name == "A")
            {
                int k = Convert.ToInt32(value);

                Debug.Log("animation " + k);

                ac.changePose(k);
            }
            else if (name == "T")
            {
                string path = savePhoto();
                unityToIOS("T," + path);

            }
            else if (name == "C")
            {

                if (type == 7)
                {

                    // 停止识别  
                    //CameraDevice.Instance.Stop();
                    //// 取消实例化摄像机
                    //CameraDevice.Instance.Deinit();
                    ////实例化相机
                    //CameraDevice.Instance.Init();

                    //// 开始识别
                    //CameraDevice.Instance.Start();



                    // for (int i = 0; i < character.Length; i++)
                    //{
                    //    GameObject a = character[i];
                    //    //Vector3 p = (Vector3)pArr[i];
                    //    //Vector3 r = (Vector3)rArr[i];
                    //    a.transform.forward = Camera.main.transform.forward;
                    //    a.transform.right= -1 * Camera.main.transform.right;
                    //    a.transform.up = Camera.main.transform.up;

                    //    a.transform.position = new Vector3(0,0,0);

                    //    a.transform.rotation = Quaternion.Euler(0.0f, 0.0f, 0.0f);
                    //    a.transform.localScale =new Vector3(1.0f, 1.0f, 1.0f);

                    //}

                    //x = 0;
                    //y = 0;
                    //z = 0;
                    //scale = 1.0f;
                    //rx = 0;
                    //ry = 0;
                    SceneManager.LoadScene(0);
                }
                else
                {
                    changeCharactorValue(type, value);
                }
               
            }
        }




    }
  
    void changeLight(int type,float value)
    {


        switch (type)
        {
            case 1:
                light.transform.Rotate(Vector3.left * (value - lx));
                lx = value;
                break;
            case 2:
                light.transform.Rotate(Vector3.up * (value - ly));
                ly = value;
                break;
            case 3:
                light.transform.Rotate(Vector3.forward * (value - lz));
                lz = value;
                break;
            case 4:
                light.intensity = value;
                break;
        }
    }

    void changeCharactorValue(int type,float value)
    {
       
        for(int i=0; i<character.Length; i++)
        {
            GameObject a = character[i];
            Vector3 p = (Vector3)pArr[i];
            Vector3 r = (Vector3)rArr[i];
            switch (type)
            {
                case 1:
                   // a.transform.Translate(new Vector3(value-x, 0,0));
                    a.transform.position += Camera.main.transform.right;
                    a.transform.position = -1 * Vector3.right * value;
                    a.transform.position += Vector3.up * y;
                    a.transform.position += Vector3.forward * z;

                    x = value;
                    //transform.Rotate(new Vector3(0, value, 0));
                    break;
                case 2:
                    // a.transform.Translate(new Vector3(0, value-y, 0));
                    a.transform.position += Camera.main.transform.up;
                    a.transform.position = Vector3.up * value;
                    a.transform.position += -1 * Vector3.right * x;
                    a.transform.position += Vector3.forward * z;

                    //transform.Rotate(new Vector3(value, 0, 0));
                    y = value;
                    break;
                case 3:
                    // a.transform.Translate(new Vector3(0, 0, value-z));
                    a.transform.position += Camera.main.transform.forward;
                    a.transform.position = Vector3.forward * value;
                    a.transform.position += -1 * Vector3.right * x;
                    a.transform.position += Vector3.up * y;
                    z = value;
                    //transform.Rotate(new Vector3(0, 0, value));
                    break;
                case 4:
                    // a.transform.Rotate(new Vector3(r.x + value,r.y, r.z));
                    a.transform.Rotate(Vector3.left * (value-rx));
                    rx = value;
                    break;
                case 5:
                    // a.transform.Rotate(new Vector3(r.x, r.y +value, r.z));
                    a.transform.Rotate(Vector3.up * (value-ry));
                    ry = value;
                    break;
                case 6:
                    a.transform.localScale = new Vector3(value, value, value);
                    scale = value;
                    break;
            }
        }

     

    }
    //void turnRight(string num)
    //{
    //    float f;
    //    Debug.Log("turnRight" + num);
    //    if (float.TryParse(num, out f))
    //    {// 将string转换为float，IOS传递数据只能用以string类型

    //        foreach (GameObject a in character)
    //        {
    //            Vector3 r = new Vector3(a.transform.rotation.x, a.transform.rotation.y - 10f, a.transform.rotation.z);
    //            a.transform.Rotate(r);
    //        }

    //    }

    //   //unityToIOS("1,2,3,4,5,6");
    //}
    //// 向左转函数接口
    //void turnLeft(string num)
    //{
    //    float f;
    //    Debug.Log("turnLeft" + num);
    //    if (float.TryParse(num, out f))
    //    {// 将string转换为float，IOS传递数据只能用以string类型

    //        foreach (GameObject a in character)
    //        {
    //            Vector3 r = new Vector3(a.transform.rotation.x+10f, a.transform.rotation.y , a.transform.rotation.z);
    //            a.transform.Rotate(r);
    //        }

    //    }

    //}



    

    //平滑旋转至自定义角度

    void OnGUI()
    {

        if (GUI.Button(new Rect(300, 10, 50, 50), "set Y"))
        {
            //自定义角度

            iosToUnity("A,1,4");
        }

        if (GUI.Button(new Rect(360, 10, 50, 50), "set -Y"))
        {
            //自定义角度

            iosToUnity("C,1,-0.5");
            iosToUnity("C,3,0.5");
            savePhoto();
        }
    }

  
}
