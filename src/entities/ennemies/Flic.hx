package entities.ennemies;
import core.Animation;
import core.SpriteSheet;
import entities.Actor;
import geom.Vec2;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

/**
 * ...
 * @author TBaudon
 */
class Flic extends Ennemy
{

	public function new() 
	{
		super("Flic");
		
		mMoveSpeed = 40;
		
		mAttackRate = 0.1;
		
		mInvincible = true;
		
		initAnimations();
	}
	
	public function pursuit(delta : Float) {
		mMoveSpeed = 60;
		attacking(delta);
	}
	
	function initAnimations() 
	{
		addAnimation("iddleR", new Animation(new SpriteSheet("Flic/flic_iddle", 140, 180, 35, 0)));
		addAnimation("iddleL", new Animation(new SpriteSheet("Flic/flic_iddle_flip", 140, 180, 35, 0)));
		
		var walkR = new Animation(new SpriteSheet("Flic/flic_walk", 140, 180, 35, 0));
		addAnimation("walkR", walkR);
		walkR.addSound(2, "sounds/stepA.mp3",0.1);
		walkR.addSound(9, "sounds/stepB.mp3",0.1);
		
		var walkL = new Animation(new SpriteSheet("Flic/flic_walk_flip", 140, 180, 35, 0));
		addAnimation("walkL", walkL);
		walkL.addSound(2, "sounds/stepA.mp3",0.1);
		walkL.addSound(9, "sounds/stepB.mp3", 0.1);
		
		var attackRAnim = new Animation(new SpriteSheet("Flic/flic_attack", 140, 180, 35, 0), null, 12, false);
		addAnimation("attackR", attackRAnim);
		attackRAnim.onFinished = normalAnim;
		attackRAnim.addSound(1, "sounds/woosh.mp3");
		
		var attackLAnim = new Animation(new SpriteSheet("Flic/flic_attack_flip", 140, 180, 35, 0), null, 12, false);
		addAnimation("attackL", attackLAnim);
		attackLAnim.onFinished = normalAnim;
		attackLAnim.addSound(1, "sounds/woosh.mp3");
	}
	
/*	override public function takeDamage(amount:Int, source:Actor) 
	{
		//super.takeDamage(amount, source);
	}
	
	/*override function draw(buffer:BitmapData, dest:Vec2) 
	{
		//super.draw(buffer, dest);
		buffer.fillRect(new Rectangle(dest.x, dest.y, mDim.x, mDim.y), 0xff0000);
	}*/
	
}