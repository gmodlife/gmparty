
local matLight 		= Material( "sprites/light_ignorez" )
local matBeam		= Material( "effects/lamp_beam" )

//ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

include('shared.lua')

function ENT:Initialize()

	self.PixVis = util.GetPixelVisibleHandle()

end

/*---------------------------------------------------------
   Name: Draw
---------------------------------------------------------*/
function ENT:Draw()	

end

function ENT:DrawTranslucent ( ) 

end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()

end

/*---------------------------------------------------------
   Name: DrawTranslucent
   Desc: Draw translucent
---------------------------------------------------------*/
function ENT:DrawTranslucent()

	
end

/*---------------------------------------------------------
   Overridden because I want to show the name of the 
   player that spawned it..
---------------------------------------------------------*/