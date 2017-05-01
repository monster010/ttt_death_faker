SWEP.Base               	= "weapon_tttbase"

SWEP.PrintName           	= "Death Faker"
SWEP.Slot                	= 6

SWEP.Primary.ClipSize    	= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo        	= "none"
SWEP.Primary.Delay       	= 10

SWEP.Secondary.Delay 		= 1
SWEP.NextRoleChange 		= 1

SWEP.HoldType            	= "slam"
SWEP.ViewModel          	= "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel          	= "models/weapons/w_c4.mdl"

SWEP.Kind               	= WEAPON_EQUIP1
SWEP.CanBuy              	= {ROLE_TRAITOR}
SWEP.LimitedStock        	= true

SWEP.CurrentRole			= {ROLE_TRAITOR, "Traitor", Color(250, 20, 20)}
SWEP.Roles					= {
	{ROLE_INNOCENT, "Innocent", Color(20, 250, 20)}, 
	{ROLE_TRAITOR, "Traitor", Color(250, 20, 20)}
}

-- Networking some stuff
function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextDMGChange")
    self:NetworkVar("Int", 0, "DMGType")
    self:NetworkVar("Int", 1, "LastIndex")
    self.BaseClass.SetupDataTables(self)
end

function SWEP:Initialize()
    self:SetDMGType(DMG_BULLET)
    self:SetNextDMGChange(0)
    self:SetLastIndex(0)
    self.BaseClass.Initialize(self)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:BodyDrop()
end

function SWEP:SecondaryAttack()
    if CurTime() < self.NextRoleChange then return end
	self.NextRoleChange = CurTime() + self.Secondary.Delay
	
	self.CurrentRole = table.FindNext(self.Roles, self.CurrentRole)
	
	if CLIENT then
		chat.AddText(Color(200, 20, 20), "[Death Faker] ", Color(250, 250, 250), "Your body's role will be ", self.CurrentRole[3], self.CurrentRole[2])
	end
end

local throwsound = Sound("physics/body/body_medium_impact_soft2.wav")
function SWEP:BodyDrop()
    if SERVER then
        local owner = self:GetOwner()
        self:FakeDeath(owner)

        self:Remove()

        owner:SetAnimation(PLAYER_ATTACK1)
    end

    self:EmitSound(throwsound)
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
end

local DMGTypes = {
    {DMG_FALL, "Fall Damage selected."},
    {DMG_CRUSH, "Crush Damage selected."},
    {DMG_BURN, "Fire Damage selected."},
    {DMG_BLAST, "Blast Damage selected."},
    {DMG_BULLET, "Bullet Damage selected."}
}

function SWEP:Reload()
    if CurTime() < self:GetNextDMGChange() then return false end

    if SERVER then
        local owner = self:GetOwner()
        local index, tab = next(DMGTypes, self:GetLastIndex())

        if index == nil then
            index, tab = next(DMGTypes, 0)
        end

        self:SetLastIndex(index)
        self:SetDMGType(tab[1])
        owner:PrintMessage(HUD_PRINTTALK, tab[2])
    end

    self:SetNextDMGChange(CurTime() + 1)

    return false
end