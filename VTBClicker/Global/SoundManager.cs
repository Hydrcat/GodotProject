using Godot;
using System;

public partial class SoundManager : Node
{
	// 单例的实现
	public static SoundManager Instance {get;private set;}
    public override void _EnterTree()
    {
        if (Instance == null)
		{
			Instance = this;
		}else{
			GD.PrintErr("instance has two!");
		}
    }

	// 单例储存的各个音频文件
	
	
		
	
}
