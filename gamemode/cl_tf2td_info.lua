GM.Damages = {};

// Soldier
GM.Damages.Soldier = {};

GM.Damages.Soldier.Price = 100;
GM.Damages.Soldier.Range = 250; 

GM.Damages.Soldier.Delay_Level1 = 2.25;
GM.Damages.Soldier.Delay_Level2 = 2; 
GM.Damages.Soldier.Delay_Level3 = 1.75;
 
GM.Damages.Soldier.Damages_Level1 = 25; 
GM.Damages.Soldier.Damages_Level2 = 50;
GM.Damages.Soldier.Damages_Level3 = 75; 
 
GM.Damages.Soldier.Radius_Level1 = 175;
GM.Damages.Soldier.Radius_Level2 = 200;
GM.Damages.Soldier.Radius_Level3 = 225;

// Scout
GM.Damages.Scout = {};

GM.Damages.Scout.Price = 130;
GM.Damages.Scout.Range = 175;
GM.Damages.Scout.Radius = 75;

GM.Damages.Scout.Delay_Level1 = 1.25;
GM.Damages.Scout.Delay_Level2 = 1;
GM.Damages.Scout.Delay_Level3 = .75;
 
GM.Damages.Scout.Damage_Level1 = 25;
GM.Damages.Scout.Damage_Level2 = 50;
GM.Damages.Scout.Damage_Level3 = 75;

// Heavy
GM.Damages.Heavy = {};

GM.Damages.Heavy.Price = 170;
GM.Damages.Heavy.Delay = .5;
GM.Damages.Heavy.Range = 175; 

GM.Damages.Heavy.Damage_Level1 = 11;
GM.Damages.Heavy.Damage_Level2 = 23;  
GM.Damages.Heavy.Damage_Level3 = 35;

// Pyro 
GM.Damages.Pyro = {}; 

GM.Damages.Pyro.Price = 150; 
GM.Damages.Pyro.Delay = .5;
GM.Damages.Pyro.Range = 150;
GM.Damages.Pyro.FireproofDamageReduction = .5;

GM.Damages.Pyro.IgniteDamageDelay = .5; 
GM.Damages.Pyro.IgniteDamage = 5; 
GM.Damages.Pyro.IgniteTimeConstant = 4;

GM.Damages.Pyro.Damage_Level1 = 5;
GM.Damages.Pyro.Damage_Level2 = 10;
GM.Damages.Pyro.Damage_Level3 = 15; 

// Demoman
GM.Damages.Demoman = {};

GM.Damages.Demoman.Price = 130; 

GM.Damages.Demoman.Delay_Level1 = 1.5;
GM.Damages.Demoman.Delay_Level2 = 1.5; 
GM.Damages.Demoman.Delay_Level3 = 1.5;

GM.Damages.Demoman.Range_Level1 = 250;
GM.Damages.Demoman.Range_Level2 = 300;
GM.Damages.Demoman.Range_Level3 = 350;
 
GM.Damages.Demoman.Damages_Level1 = 25;
GM.Damages.Demoman.Damages_Level2 = 50; 
GM.Damages.Demoman.Damages_Level3 = 75;
 
GM.Damages.Demoman.Radius_Level1 = 200;
GM.Damages.Demoman.Radius_Level2 = 200;
GM.Damages.Demoman.Radius_Level3 = 200;

// Spy
GM.Damages.Spy = {};

GM.Damages.Spy.Price = 175;
GM.Damages.Spy.Range = 350;
GM.Damages.Spy.CritMul = 2;

GM.Damages.Spy.Delay_Level1 = 2;
GM.Damages.Spy.Delay_Level2 = 1.75;
GM.Damages.Spy.Delay_Level3 = 1.5; 
 
GM.Damages.Spy.Damage_Level1 = 20;
GM.Damages.Spy.Damage_Level2 = 40;
GM.Damages.Spy.Damage_Level3 = 60;

// Medic
GM.Damages.Medic = {};

GM.Damages.Medic.Price = 200;
GM.Damages.Medic.Delay = 1.5;
GM.Damages.Medic.Range = 300; 

GM.Damages.Medic.DiseaseTimeConstant = 3;
GM.Damages.Medic.DiseaseDamageDelay = .5;
GM.Damages.Medic.DiseaseDamageConstant = 5;

GM.Damages.Medic.Damage_Level1 = 10;
GM.Damages.Medic.Damage_Level2 = 15;
GM.Damages.Medic.Damage_Level3 = 20;

// Sniper
GM.Damages.Sniper = {};

GM.Damages.Sniper.Price = 220;
GM.Damages.Sniper.JarateDelay = 10;
GM.Damages.Sniper.JarateDuration = 20;
 
GM.Damages.Sniper.Range = 750;

GM.Damages.Sniper.Delay_Level1 = 3;
GM.Damages.Sniper.Delay_Level2 = 3;
GM.Damages.Sniper.Delay_Level3 = 3;

GM.Damages.Sniper.Damage_Level1 = 35; 
GM.Damages.Sniper.Damage_Level2 = 80;
GM.Damages.Sniper.Damage_Level3 = 120; 

GM.RunnerConfig = {};

local TierOneReward = 35;
local TierTwoReward = 45;
local TierThreeReward = 50;  

// Soldier
GM.RunnerConfig.Soldier = {};

GM.RunnerConfig.Soldier.Health = 225;
GM.RunnerConfig.Soldier.Speed = 170;
GM.RunnerConfig.Soldier.Reward = TierOneReward;

// Demoman
GM.RunnerConfig.Demoman = {};

GM.RunnerConfig.Demoman.Health = 180; 
GM.RunnerConfig.Demoman.Speed = 200;
GM.RunnerConfig.Demoman.Reward = TierOneReward;

// Engineer
GM.RunnerConfig.Engineer = {};

GM.RunnerConfig.Engineer.Health = 250;
GM.RunnerConfig.Engineer.Speed = 190;
GM.RunnerConfig.Engineer.Reward = TierOneReward;

// Scout
GM.RunnerConfig.Scout = {};

GM.RunnerConfig.Scout.Health = 170;
GM.RunnerConfig.Scout.Speed = 320; 
GM.RunnerConfig.Scout.Reward = TierTwoReward;

// Heavy
GM.RunnerConfig.Heavy = {};

GM.RunnerConfig.Heavy.Health = 600; 
GM.RunnerConfig.Heavy.Speed = 100;
GM.RunnerConfig.Heavy.Reward = TierTwoReward;

// Pyro
GM.RunnerConfig.Pyro = {};

GM.RunnerConfig.Pyro.Health = 180;
GM.RunnerConfig.Pyro.Speed = 200;
GM.RunnerConfig.Pyro.Reward = TierTwoReward;


// Spy
GM.RunnerConfig.Spy = {};

GM.RunnerConfig.Spy.Health = 130;
GM.RunnerConfig.Spy.Speed = 200;
GM.RunnerConfig.Spy.Reward = TierThreeReward;

// Sniper
GM.RunnerConfig.Sniper = {};

GM.RunnerConfig.Sniper.JarateDelay = 10;
GM.RunnerConfig.Sniper.JarateTime = 10;
GM.RunnerConfig.Sniper.DelayMul = 1.5;

GM.RunnerConfig.Sniper.Health = 260;
GM.RunnerConfig.Sniper.Speed = 200;
GM.RunnerConfig.Sniper.Reward = TierThreeReward;

// Medic
GM.RunnerConfig.Medic = {};

GM.RunnerConfig.Medic.HealDistance = 500; 
GM.RunnerConfig.Medic.HealAmmount = 3;
GM.RunnerConfig.Medic.HealDelay = 1;

GM.RunnerConfig.Medic.Health = 270;
GM.RunnerConfig.Medic.Speed = 200;
GM.RunnerConfig.Medic.Reward = TierThreeReward;