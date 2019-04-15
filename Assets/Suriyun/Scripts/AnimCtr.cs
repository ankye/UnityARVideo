using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimCtr : MonoBehaviour {

    public Animator animator;
    public int pos;
    public bool change;

	// Use this for initialization
	void Start () {
        this.pos = 0;
        this.change = true;
	}
	

    // Update is called once per frame
    void Update () {

        if (this.change)
        {

            this.change = false;
            Reset();
            switch (this.pos)
            {
                case 0:
                    animator.SetBool("0_1", true);
                    break;
                case 1:
                    animator.SetBool("5_6", true);
                    break;
                case 2:
                    animator.SetBool("10_11", true);
                    break;
                case 3:
                    animator.SetBool("15_16", true);
                    break;
                case 4:
                    animator.SetBool("20_21", true);
                    break;
                case 5:
                    animator.SetBool("25_26", true);
                    break;
                case 6:
                    animator.SetBool("29_30", true);
                    break;
                case 7:
                    animator.SetBool("34_35", true);
                    break;
            }

        }

    }

    private void Reset()
    {
        animator.SetBool("0_1", false);
        animator.SetBool("10_11", false);
        animator.SetBool("15_16", false);
        animator.SetBool("20_21", false);
        animator.SetBool("25_26", false);
        animator.SetBool("29_30", false);
        animator.SetBool("34_35", false);
        animator.SetBool("5_6", false);
    }

    internal void changePose(int k)
    {

        this.pos = k;
        this.change = true;
    }
}
