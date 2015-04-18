package entities.hero;
import core.Animation;
import core.SpriteSheet;
import entities.Weapon;
import geom.Vec2;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

/**
 * ...
 * @author TBaudon
 */
class Callbut extends Weapon
{

	public function new() 
	{
		super("Callbut");
		
		mDamage = 5;
		
		initAnimations();
	}
	
	function initAnimations() 
	{
		addAnimation("idleR", new Animation(new SpriteSheet("Hero/slip_iddle", 140, 180, 35, 0)));
		addAnimation("idleL", new Animation(new SpriteSheet("Hero/slip_iddle_flip", 140, 180, 35, 0)));
		
		addAnimation("walkR", new Animation(new SpriteSheet("Hero/slip_run", 140, 180, 35, 0),null,16));
		addAnimation("walkL", new Animation(new SpriteSheet("Hero/slip_run_flip", 140, 180, 35, 0), null, 16));
		
		var kickLRAnim = new Animation(new SpriteSheet("Hero/slip_kickL", 140, 180, 35, 0), null, 12, false); 
		addAnimation("kickLR", kickLRAnim);
		
		var kickLLAnim = new Animation(new SpriteSheet("Hero/slip_kickL_flip", 140, 180, 35, 0), null, 12, false); 
		addAnimation("kickLL", kickLLAnim);
		
		var kickLRAnim = new Animation(new SpriteSheet("Hero/slip_kickD", 140, 180, 35, 0), null, 12, false); 
		addAnimation("kickDR", kickLRAnim);
		
		var kickLLAnim = new Animation(new SpriteSheet("Hero/slip_kickD_flip", 140, 180, 35, 0), null, 12, false); 
		addAnimation("kickDL", kickLLAnim);
		
		var stripRAnim = new Animation(new SpriteSheet("Hero/slip_strip", 140, 180, 35, 0), null, 12, false);
		addAnimation("stripR", stripRAnim);
		
		var stripLAnim = new Animation(new SpriteSheet("Hero/slip_strip_flip", 140, 180, 35, 0), [7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8], 12, false);
		addAnimation("stripL", stripLAnim);
	}
	
}