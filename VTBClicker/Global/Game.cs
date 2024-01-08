using Godot;
using System;
using System.Security.Cryptography.X509Certificates;

public partial class Game : Node
{
	[Export] Clicker clicker;
	[Export] Timer timer;
    public override void _Ready()
    {
        clicker.Clicked += OnClicked;
		timer.Timeout += OnSecondTimerEnd;
    }
    // 粉丝数量
    public int Fans {get;private set;}= 0;
	// 每秒增加fans数量
	public float FansPerSecond {get;private set;}= 0.0f; 
	// 点击增加fans数量
	public int FansPerClick {get;private set;} = 1;
	
	private float fansToAdd = 0.0f;

	private void OnClicked()
	{
		Fans += FansPerClick;
		GD.Print(Fans);
	}

	private void OnSecondTimerEnd()
	{
		fansToAdd += FansPerSecond;
		var add = Mathf.FloorToInt(fansToAdd);
		Fans += add;
		fansToAdd -= add;
		GD.Print(Fans);
	}

	
}
