/*
 
    -----------------------
    UDP-Receive (send to)
    ----------------------
   
    // > receive
    // 127.0.0.1 : 8051
   
    // send
    // nc -u 127.0.0.1 8051
 
*/
using UnityEngine;
using UnityEditor;
using System.Collections;

using System;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Collections.Generic;
using UnityEngine.Rendering;

public class UDPReceiveBulk : MonoBehaviour
{

    // receiving Thread
    Thread receiveThread;

    // udpclient object
    UdpClient client;
	
	public GameObject rso;

    // public
    // public string IP = "127.0.0.1"; default local
    public int port; // define > init

    // infos
    public ulong counter = 0;
    public string lastReceivedUDPPacket = "";
    public string allReceivedUDPPackets = ""; // clean up this from time to time!

    public Boolean initFlag = true;
    public Boolean exitFlag = false;

    public int num = 0;
    public int max = 500;
    public Transform[] gameObjArr;
    public int objectCounter;
    public Vector3[] pastPosArr;
    public int timeStepPrev = 0;
    //public GameObject sphereObj;
    public Queue<int[]> queue = new Queue<int[]>();
    private float distMult = 0.012F;
    //public Stack stack = new Stack();




    // start from shell
    private static void Main()
    {

        UDPReceiveBulk receiveObj = new UDPReceiveBulk();
        receiveObj.init();
        GameObject sphereObj = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        //GameObject sphereObj = GameObject.CreatePrimitive(PrimitiveType.Sphere);

        string text = "";
        do
        {
            text = Console.ReadLine();
        }
        while (!text.Equals("exit"));
    }
    // start from unity3d
    public void Start()
    {

        init();
        
    }

    // OnGUI
    void OnGUI()
    {
        Rect rectObj = new Rect(40, 10, 200, 400);
        GUIStyle style = new GUIStyle();
        style.alignment = TextAnchor.UpperLeft;
        GUI.Box(rectObj, "# UDPReceive\n" + port + " #\n"
                    + "shell> nc -u: " + port + " \n"
                    + "\nLast Packet: \n" + lastReceivedUDPPacket
                    //+ "\n\nAll Messages: \n" + allReceivedUDPPackets
                    + "\n\nCounter: \n" + counter
                , style);
    }

    private void init()
    {
        
        Resources.UnloadUnusedAssets();
        System.GC.Collect();
        print("UDPRecieve.init()");

        // define port
        port = 8051;
        //sphereObj = GameObject.CreatePrimitive(PrimitiveType.Sphere);

        receiveThread = new Thread(
            new ThreadStart(ReceiveData));
        receiveThread.IsBackground = true;
        receiveThread.Start();

    }

    // receive thread
    private void ReceiveData()
    {
        client = new UdpClient(port);
        client.Client.ReceiveBufferSize = 65536;

        while (exitFlag == false)
        {
            try
            {
                IPEndPoint anyIP = new IPEndPoint(IPAddress.Any, 0);
                byte[] data = client.Receive(ref anyIP);
                
                //If init flag set up object array with recieved number of objects
                if (initFlag) {
                    num = BitConverter.ToInt32(data, 0);
                    gameObjArr = new Transform[num];
                    pastPosArr = new Vector3[num];
                    print("num is" + num);
                } else {
                    int p;
                    for (p=0; p < num; p++)
                    {
                        int[] currObj = new int[4];
                        int position = p;
                        currObj[0] = position;

                        currObj[1] = BitConverter.ToInt16(data, (p*2));
                        currObj[2] = BitConverter.ToInt16(data, num * 2+(p*2));
                        currObj[3] = BitConverter.ToInt16(data,  num * 4 + (p * 2));

                        if (position > 0 && position <= num)
                        {
                            if (currObj.Length != 0)
                            {
                                queue.Enqueue(currObj);
                            } else
                            {
                                print("Outputting temp  " + currObj[0] + " " + currObj[1] + " " + currObj[2] + " " + currObj[3] + " ");
                            }
                        }
                    }

                    counter += 1;
                }


            }
            catch (Exception err)
            {
                print(err.ToString());
            }
        }
    }

    // getLatestUDPPacket
    // cleans up the rest
    public string getLatestUDPPacket()
    {
        allReceivedUDPPackets = "";
        return lastReceivedUDPPacket;
    }

    void Update()
    {
        //f is a counter counting the number updates since a new set of positions have been queued
        //Resources.UnloadUnusedAssets();

        //On first connect (object num recieved)
        if (initFlag && num != 0)
        {
            initFlag = false;
            for (int j = 0; j < num; j++)
            {
                GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                sphere.transform.position = new Vector3(UnityEngine.Random.value * max - (max / 2), UnityEngine.Random.value * max - (max / 2), UnityEngine.Random.value * max - (max / 2));
                MeshRenderer renderer = sphere.GetComponent<MeshRenderer>();

                sphere.tag = "Sup";
                sphere.isStatic = false;
                renderer.material.color = new Color(2f, 1, 1);
                Physics.IgnoreCollision(sphere.GetComponent<Collider>(), GetComponent<Collider>());
                renderer.shadowCastingMode = ShadowCastingMode.Off;
                gameObjArr[j] = sphere.transform;
            }
        }
        
        
        while (queue.Count > 0)
        {
         
            int[] temp = queue.Dequeue();
            int p = -1;
            
            if (temp != null)
            {
                try
                {
                    p = temp[0];
             
                    p -= 1;


                    if (gameObjArr[p] != null)
                    {
                        Vector3 v = new Vector3(temp[1] * distMult, temp[3] * distMult, temp[2] * distMult);
                        gameObjArr[p].position = v;
                    }
                    
                }
                catch (Exception e)
                {
                    print(e);
                    print(temp);
                }
            }
        }
    }

    void OnApplicationQuit()
    {


        if (receiveThread != null)
            receiveThread.Abort();
        if (client != null)
            client.Close();
        exitFlag = true;

        Resources.UnloadUnusedAssets();

    }
}