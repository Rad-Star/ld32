package entities.hero;
import core.Animation;
import core.Camera;
import core.Entity;
import core.SpriteSheet;
import entities.Actor;
import entities.ennemies.Ennemy;
import entities.ennemies.Flic;
import entities.Human;
import entities.Thorn;
import entities.Weapon;
import entities.World;
import geom.Vec2;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.media.Sound;
import openfl.ui.Keyboard;

/**
 * ...
 * @author TBaudon
 */
class Hero extends Human
{
	var mCDown:Bool;
	var mXDown:Bool;
	
	var mShoes : Array<Shoe>;
	var mPant : Pant;
	var mCalbut : Callbut;
	var mPull : Pull;
	var mKick : Kick;
	
	var mWorld : World;
	var mShoeLaunched = false;
	
	var mCurrentState : Float -> Void;
	var mLastStripableBody:Actor;
	var mCacUsed:Bool;
	var mCacStarted:Bool;
	var mCatched:Bool;
	
	var mHurtSnd : Sound;
	
	public static inline var HERO : String = "Hero";

	public function new(world : World) 
	{
		super(HERO);
		
		mDim.x = 65; 
		mDim.y = 170;
		
		mHurtSnd = Assets.getSound("sounds/punchA.mp3");
		
		mWorld = world;
		
		mKick = new Kick();
	
		initClothes();
		giveClothes();
		
		initAnimations();
		
		addListeners();
		
		mCurrentState = normalState;
	}
	
	///// clothes
	
	function initClothes() 
	{
		mShoes = new Array<Shoe>();
	}
	
	function giveClothes() : Void {
		giveShoe();
		giveShoe();
		giveCallbut();
		givePant();
		givePull();
		mLife = 5;
	}
	
	public function spawnTorn() {
		var parent : World = cast parent;
		parent.addActor(new Thorn(this));
	}
	
	public function giveShoe() {
		var shoe : Shoe;
		if (mShoes.length == 0){
			shoe = new Shoe("R");
		}
		else if (mShoes.length == 1) {
			shoe = new Shoe("L");
		}
		else
			return;
			
		add(shoe);
		mShoes.push(shoe);
	}
	
	public function giveCallbut() {
		if (mCalbut != null) return;
		else {
			mCalbut = new Callbut();
			add(mCalbut);
		}
	}
	
	public function givePant() {
		if (mPant != null) return;
		else {
			mPant = new Pant();
			add(mPant);
		}
	}
	
	public function givePull() {
		if (mPull != null) return;
		else {
			mPull = new Pull();
			add(mPull);
		}
	}
	
	///// end clothes
	
	function addListeners() 
	{
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	override function playAnim(name : String) : String{
		name = super.playAnim(name);
		
		if (mCalbut != null) 
			mCalbut.setAnimation(name);
			
		if (mPull != null)
			mPull.setAnimation(name);
			
		if (mPant != null)
			mPant.setAnimation(name);
			
		for (shoe in mShoes) shoe.setAnimation(name);
		
		return name;
	}
	
	public function isAttacking() : Bool {
		return isPlaying("cac") || isPlaying("kickR") || isPlaying("kickL");
	}
	
	function onKeyUp(e:KeyboardEvent):Void 
	{
		switch (e.keyCode) {
			case Keyboard.X :
				mXDown = false;
			case Keyboard.C :
				mCDown = false;
			case Keyboard.UP :
				if(mYAxis == -1)
					mYAxis = 0;
			case Keyboard.DOWN :
				if(mYAxis == 1)
					mYAxis = 0;
			case Keyboard.LEFT :
				if(mXAxis == -1)
					mXAxis = 0;
			case Keyboard.RIGHT :
				if (mXAxis == 1) 
					mXAxis = 0;
		}
	}
	
	function onKeyDown(e:KeyboardEvent):Void 
	{
		if (isDead()) return; 
		
		switch (e.keyCode) {
			case Keyboard.C :
				if(!mCDown){
					rangedAttack();
					mCDown = true;
				}
			case Keyboard.X : 
				if (!mXDown) {
					onXPressed();
					mXDown = true;
				}
			case Keyboard.UP :
				mYAxis = -1;
			case Keyboard.DOWN :
				mYAxis = 1;
			case Keyboard.LEFT :
				mXAxis = -1;
			case Keyboard.RIGHT :
				mXAxis = 1;
		}
	}
	
	function onXPressed(){
		if (mLastStripableBody != null && 
			hitTest(this, mLastStripableBody) &&
			worldPos.y <= mLastStripableBody.worldPos.y)
			stripBody();
		else if(mCurrentState != attackState)
			attack();
	}
	
	function attack() {
		mCurrentState = attackState;
		mCacUsed = false;
		mCacStarted = false;
	}
	
	function attackState(delta : Float) {
		unpushable = true;
		mMoveSpeed = 0;
		
		var currentWeapon : Weapon = null;
		
		if (mPull != null ) 
			currentWeapon = mPull;
		else if (mPant != null) 
			currentWeapon = mPant;
		else
			currentWeapon = mKick;
			
		
		var frameToDamage = 5;
		if (currentWeapon == mKick)
			frameToDamage = 3;
		
		if (!mCacStarted && currentWeapon != null) {
			if (currentWeapon != mKick){
				playAnim("cac");
				spawnTorn();
			}
			else {
				var a = Math.random() * 100 - 50;
				if(a > 0)
					playAnim("kickL");
				else
					playAnim("kickD");
			}
		
			mCacStarted = true;
			if(currentWeapon != mKick)
				remove(currentWeapon);
		}
		
		if (currentWeapon != null && mAnimation.getCurrentFrame() == frameToDamage && !mCacUsed) {
			mCacUsed = true;
			currentWeapon.launch(mHeading);
			mWorld.addActor(currentWeapon);
			currentWeapon.startAltitude = 1;
			currentWeapon.worldPos.x = worldPos.x + 60 * mHeading;
			currentWeapon.worldPos.y = worldPos.y;
			
			if (currentWeapon == mPull)
				mPull = null;
			else if(currentWeapon == mPant)
				mPant = null;
			else
				mKick = new Kick();
			currentWeapon = null;
		}
		
	}
	
	function stripBody() {
		setStripState();
	}
	
	function stripEnded() {
		giveClothes();
		setNormalState();
		mLastStripableBody.destroy();
		mLastStripableBody = null;
	}
	
	override function update(delta:Float) 
	{
		super.update(delta);
		
		synchronizeClothes();
		
		if (mXAxis < 0)
			mHeading = -1;
		else if (mXAxis > 0)
			mHeading = 1;
		
		if (mCurrentState != null)
			mCurrentState(delta);
		
	}
	
	function synchronizeClothes() 
	{
		if (mAnimation == null) return;
		var frame = mAnimation.getCurrentFrame();
		for (shoe in mShoes)
			shoe.synchronize(frame);
			
		if (mPull != null)
			mPull.synchronize(frame);
		
		if (mPant != null)
			mPant.synchronize(frame);
			
		if (mCalbut != null)
			mCalbut.synchronize(frame);
	}
	
	function normalState(delta : Float) {
		playAnim("idle");
		
		unpushable = false;
		
		mMoveSpeed = 100;
		
		if (vel.length() > 15)
			setWalkState();
	}
	
	function kickState(delta : Float) {
		
		mMoveSpeed = 0;
		
		unpushable = true;
		
		if(!mShoeLaunched){
			if(mShoes.length > 1)
				playAnim("kickL");
			else 
				playAnim("kickD");
		}
			
		if (mAnimation.getCurrentFrame() == 3 && !mShoeLaunched)
		{
			var shoe : Shoe = mShoes.pop();
			remove(shoe);
			shoe.launch(mHeading);
			mWorld.addActor(shoe);
			shoe.startAltitude = 70;
			shoe.worldPos.x = worldPos.x + 50 * mHeading;
			shoe.worldPos.y = worldPos.y;
			mShoeLaunched = true;
			if (mHeading > 0)
				shoe.setAnimation("launchedR");
			else
				shoe.setAnimation("launchedL");
		}
	}
	
	public function isFacingRight() : Bool {
		return mHeading > 0;
	}
	
	function slipState(delta : Float) {
		
		unpushable = true;
		
		if (mCalbut != null) {
			remove(mCalbut);
		}
		
		if (mAnimation.getCurrentFrame() == 6 && mCalbut != null)
		{
			mCalbut.launch(mHeading);
			mWorld.addActor(mCalbut);
			mCalbut.startAltitude = 120;
			mCalbut.worldPos.x = worldPos.x + 50 * mHeading;
			mCalbut.worldPos.y = worldPos.y;
			if (mHeading > 0)
				mCalbut.setAnimation("launchedR");
			else
				mCalbut.setAnimation("launchedL");
			mCalbut = null;
		}
		
		mMoveSpeed = 0;
		
		playAnim("slip");
	}
	
	function walkState(delta : Float) {
		playAnim("walk");
		
		if (vel.length() < 15)
			setNormalState();
	}
	
	function stripState(delta : Float) {
		unpushable = true;
		playAnim("strip");
		
		mMoveSpeed = 0;
		
	}
	
	function setNormalState() {
		mCurrentState = normalState;
	}
	
	function setKickState() {
		mShoeLaunched = false;
		mCurrentState = kickState;
	}
	
	function setWalkState() {
		mCurrentState = walkState;
	}
	
	function setStripState() {
		mCurrentState = stripState;
	}
	
	function setSlipState() {
		mCurrentState = slipState;
	}
	
	
	function rangedAttack() 
	{
		if (mShoes.length > 0) 
			setKickState();
		else if (mCalbut != null && mPant == null)
			setSlipState();
	}
	
	override public function onCollide(actor:Actor) 
	{
		super.onCollide(actor);
		
		if (Std.is(actor, Ennemy) && actor.isDead()) {
			if (worldPos.y < actor.worldPos.y)
				mLastStripableBody = actor;
		}
	}
	
	override public function takeDamage(amount:Int, source:Actor) 
	{
		
		if (Std.is(source, Flic)){
			die();
			return;
		}
		
		super.takeDamage(amount, source);
		
		mGame.flash(0xff3333, 0.05);
		Camera.instance.shake(10, 200);
		
		mLife = 5; 
		
		mHurtSnd.play();
		
		if (mPull != null) {
			remove(mPull);
			mPull = null;
			spawnTorn();
		}else if (mShoes.length > 0) 
			remove(mShoes.pop());
		else if (mPant != null) {
			remove(mPant);
			mPant = null;
			spawnTorn();
		}else if (mCalbut != null) {
			remove(mCalbut);
			mCalbut = null;
		}
	}
	
	public function isApoil() : Bool {
		return mCalbut == null;
	}
	
	function die() 
	{
		mLife = 0;
		mCurrentState = deadState;
		playAnim("catch");
	}
	
	function deadState(delta : Float) {
		mMoveSpeed = 0;
	}
	
	function onCatched() {
		mCatched = true;
	}
	
	public function isCaught() : Bool {
		return mCatched;
	}
	
	function initAnimations():Void 
	{
		addAnimation("idleR", new Animation(new SpriteSheet("Hero/franky_iddle", 140, 180, 35, 0))); 
		addAnimation("idleL", new Animation(new SpriteSheet("Hero/franky_iddle_flip", 140, 180, 35, 0))); 
		
		var runR = new Animation(new SpriteSheet("Hero/franky_run", 140, 180, 35, 0), null, 16);
		addAnimation("walkR", runR); 
		runR.addSound(2, "sounds/stepA.mp3",0.25);
		runR.addSound(5, "sounds/stepB.mp3",0.25);
		
		var runD = new Animation(new SpriteSheet("Hero/franky_run_flip", 140, 180, 35, 0), null, 16);
		addAnimation("walkL", runD); 
		runD.addSound(2, "sounds/stepA.mp3", 0.25);
		runD.addSound(5, "sounds/stepB.mp3", 0.25);
		
		var kickLRAnim = new Animation(new SpriteSheet("Hero/franky_kickL", 140, 180, 35, 0), null, 22, false); 
		kickLRAnim.onFinished = setNormalState;
		kickLRAnim.addSound(1, "sounds/woosh.mp3");
		addAnimation("kickLR", kickLRAnim);
		
		var kickLLAnim = new Animation(new SpriteSheet("Hero/franky_kickL_flip", 140, 180, 35, 0), null, 22, false); 
		kickLLAnim.onFinished = setNormalState;
		kickLLAnim.addSound(1, "sounds/woosh.mp3");
		addAnimation("kickLL", kickLLAnim);
		
		var kickLRAnim = new Animation(new SpriteSheet("Hero/franky_kickD", 140, 180, 35, 0), null, 22, false); 
		kickLRAnim.onFinished = setNormalState;
		kickLRAnim.addSound(1, "sounds/wooshB.mp3");
		addAnimation("kickDR", kickLRAnim);
		
		var kickLLAnim = new Animation(new SpriteSheet("Hero/franky_kickD_flip", 140, 180, 35, 0), null, 22, false); 
		kickLLAnim.onFinished = setNormalState;
		kickLLAnim.addSound(1, "sounds/wooshB.mp3");
		addAnimation("kickDL", kickLLAnim);
		
		var stripRAnim = new Animation(new SpriteSheet("Hero/franky_strip", 140, 180, 35, 0), [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], 20, false);
		stripRAnim.onFinished = stripEnded;
		addAnimation("stripR", stripRAnim);
		
		var stripLAnim = new Animation(new SpriteSheet("Hero/franky_strip_flip", 140, 180, 35, 0), [8,7,6,5,4,3,2,1,0,16,15,14,13,12,11,10,9], 20, false);
		stripLAnim.onFinished = stripEnded;
		addAnimation("stripL", stripLAnim);
		
		var slipRAnim = new Animation(new SpriteSheet("Hero/franky_slip", 140, 180, 35, 0), null, 16, false);
		slipRAnim.onFinished = setNormalState;
		slipRAnim.addSound(1, "sounds/wooshB.mp3");
		addAnimation("slipR", slipRAnim);
		
		var slipLAnim = new Animation(new SpriteSheet("Hero/franky_slip_flip", 140, 180, 35, 0), null, 16, false);
		slipLAnim.onFinished = setNormalState;
		slipRAnim.addSound(1, "sounds/wooshB.mp3");
		addAnimation("slipL", slipLAnim);
		
		var cacRAnim = new Animation(new SpriteSheet("Hero/franky_cac", 140, 180, 35, 0), null, 12, false);
		cacRAnim.onFinished = setNormalState;
		cacRAnim.addSound(1, "sounds/wooshB.mp3");
		addAnimation("cacR", cacRAnim);
		
		var cacLAnim = new Animation(new SpriteSheet("Hero/franky_cac_flip", 140, 180, 35, 0), null, 12, false);
		cacLAnim.onFinished = setNormalState;
		cacLAnim.addSound(1, "sounds/wooshB.mp3");
		addAnimation("cacL", cacLAnim);
		
		var catchRAnim = new Animation(new SpriteSheet("Hero/franky_catch", 140, 180, 35, 0), null, 12, false);
		catchRAnim.onFinished = onCatched;
		addAnimation("catchR", catchRAnim);
		
		var catchLAnim = new Animation(new SpriteSheet("Hero/franky_catch_flip", 140, 180, 35, 0), null, 12, false);
		catchLAnim.onFinished = onCatched;
		addAnimation("catchL", catchLAnim);
		
		
	}
	
}