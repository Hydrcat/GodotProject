using Godot;

public partial class Game : Node
{
	[Export] Clicker clicker;
	[Export] Timer timer;
	public static Game Instance {get;private set;}

	[Signal] public delegate void FansUpdatedEventHandler(int newFans);

    public override void _EnterTree()
    {
       	if (Instance == null)
		{
			Instance = this;
		}else{
			GD.PrintErr("Game has two diff instance:"+Instance+","+this);
		}
    }
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
		// 调用ui，更新
		EmitSignal(SignalName.FansUpdated,Fans);

	}

	private void OnSecondTimerEnd()
	{
		fansToAdd += FansPerSecond;
		var add = Mathf.FloorToInt(fansToAdd);
		Fans += add;
		fansToAdd -= add;
	}

	
}
