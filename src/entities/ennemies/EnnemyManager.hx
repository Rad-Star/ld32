package entities.ennemies;
import core.Game;
import entities.ennemies.Ennemy;
import entities.hero.Hero;

/**
 * ...
 * @author TBaudon
 */
class EnnemyManager
{
	
	var mEnnemies : Array<Ennemy>;
	var mAttackingEnnemies : Array<Ennemy>;
	
	var mEnnemiesToRemove : Array<Ennemy>;
	
	var mFlic : Flic;
	
	var mWorld : World;
	var mGame : Game;
	var mHero : Hero;
	
	var mWave : Int;
	
	public function new(hero : Hero, world : World) 
	{
		mHero = hero;
		mWorld = world;
		mGame = Game.getInstance();
		mFlic = new Flic();
		
		mWorld.addActor(mFlic);
		
		mFlic.worldPos.x = 400;
		mFlic.worldPos.y = 300 / Actor.fakeZCoef;
		mFlic.setTarget(mHero);
		mFlic.setState(mFlic.getClose);
		
		mEnnemies = new Array<Ennemy>();
		mEnnemiesToRemove = new Array<Ennemy>();
		mAttackingEnnemies = new Array<Ennemy>();
	}
	
	public function spawnPunk(wave : Int) {
		
		mWave = wave;
		
		var punkToSpawn : Int = Std.int(2 * wave * wave / 3);
		if (punkToSpawn < 2) punkToSpawn = 2;
		
		if (wave > 0)
		{
			punkToSpawn = 0;
			var boss = new Boss();
			mEnnemies.push(boss);
			mWorld.addActor(boss);
		}
		
		for (i in 0 ... punkToSpawn) {
			var punk = new Punk();
			
			var min = (mGame.getHeight() / 2) / Actor.fakeZCoef;
			var max = (mGame.getHeight()) / Actor.fakeZCoef;
			
			punk.worldPos.y = Math.random() * (max - min) + min;
			
			var a = Math.random() * 100 - 50;
			
			var dist = Math.random() * 300 + 800;
			
			if (a > 0)
				punk.worldPos.x = mHero.worldPos.x + dist;
			else {
				if(wave > 2)
					punk.worldPos.x = mHero.worldPos.x - dist;
				else
					punk.worldPos.x = mHero.worldPos.x + dist;
			}
			mWorld.addActor(punk);
			mEnnemies.push(punk);
		}
		
	}
	
	public function update() {
		
		for (ennemy in mEnnemies) {
			// add to destruction
			if (ennemy.isDead()){
				mEnnemiesToRemove.push(ennemy);
				continue;
			}
			
			ennemy.setTarget(mHero);
			
			var isAttacking : Bool = mAttackingEnnemies.indexOf(ennemy) != -1;
				
			if (mAttackingEnnemies.length < mWave * 1) { 
				if (!isAttacking){
					mAttackingEnnemies.push(ennemy);
					ennemy.setState(ennemy.attacking);
				}
			}else if(!isAttacking)
				ennemy.setState(ennemy.getClose);

		}
		
		if (mHero.isApoil())
			mFlic.setState(mFlic.pursuit);
		else
			mFlic.setState(mFlic.getClose);
		
		while (mEnnemiesToRemove.length > 0) {
			var ennemy = mEnnemiesToRemove.pop();
			var a = mAttackingEnnemies.remove(ennemy);
			mEnnemies.remove(ennemy);
		}
		
		for (a in mAttackingEnnemies)
			if (a.isDead())
				trace("putain");
	}
	
	public function getEnnemiesAlive() : Int {
		return mEnnemies.length;
	}
	
}