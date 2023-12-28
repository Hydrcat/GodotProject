using Godot;


public partial class Click : Area2D
{
	private Tween tween;
    public override void _InputEvent(Viewport viewport, InputEvent @event, int shapeIdx)
    {
        base._InputEvent(viewport, @event, shapeIdx);

		if (@event.IsActionPressed("click")){
			if (tween != null)
			{
				tween.Kill();
			}
			tween = CreateTween();

			tween.SetEase(Tween.EaseType.Out).SetTrans(Tween.TransitionType.Sine).Parallel();
			tween.TweenProperty(this,"scale",new Vector2(),0.2);
			tween.TweenProperty(this,"rotation",Vector2.One*1.3,0.2);
		}
    }
}
