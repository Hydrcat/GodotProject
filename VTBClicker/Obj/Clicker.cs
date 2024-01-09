using Godot;

public partial class Clicker : Area2D
{
private Tween tween;

    [Export] private float RoateSpeed;

	[Signal] public delegate void ClickedEventHandler(); // 本质是声明了一个委托，引擎通过[singal]关键字创建了实例，并去掉了EventHandler

    public override void _Ready()
    {
        Clicked += OnClicked;
    }
    public override void _Process(double delta)
	{
		Rotate((float)delta * RoateSpeed);
	}

    public override void _MouseEnter()
    {
        tween?.Kill();
		tween = CreateTween();
		tween.SetEase(Tween.EaseType.In).SetTrans(Tween.TransitionType.Bounce);
		tween.TweenProperty(this,"scale",Vector2.One * 1.15f,0.3);
    }
    public override void _MouseExit()
    {
        tween?.Kill();
		tween = CreateTween();
		tween.SetEase(Tween.EaseType.Out).SetTrans(Tween.TransitionType.Bounce);
		tween.TweenProperty(this,"scale",Vector2.One,0.3);
    }

	private void OnClicked(){
		tween?.Kill();
		tween = CreateTween();
		tween.SetEase(Tween.EaseType.Out).SetTrans(Tween.TransitionType.Sine).Chain();
		tween.TweenProperty(this,"scale",Vector2.One * 1.3f,0.3).From(Vector2.One* 1.15f);
		tween.TweenProperty(this,"scale",Vector2.One * 1.15f,0.1);
	}

    public override void _InputEvent(Viewport viewport, InputEvent @event, int shapeIdx)
    {
		if (@event.IsActionPressed("Click"))
		{
			// 发出点击信号
			EmitSignal(SignalName.Clicked);
		}

    }
}
