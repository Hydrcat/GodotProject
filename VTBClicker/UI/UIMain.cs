using Godot;

public partial class UIMain : Control
{
	[Export] private Label numberLabel;
    public override void _Ready()
    {
		Game.Instance.FansUpdated += OnFansUpdated;
    }

    private void OnFansUpdated(int newFans)
    {
        numberLabel.Text = newFans.ToString();
    }

}
