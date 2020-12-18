const DIM = 61
const E_Flexible = 68900
const E_Stiff = 1.6e+07
const E_Expand = 2.0e+07
const ρ = 10700 

function make_circle!(layer)
  center = div(DIM, 2) + 1
  radius = DIM/2
  for x in 1:DIM
    for y in 1:DIM
      if √((x-center)^2 + (y-center)^2) > radius
        layer[x, y] = 0
      end
    end
  end
end

l1 = ones(Int, DIM, DIM)
for i in 11:10:DIM-10
  l1[i, :] .*= 2
end
make_circle!(l1)

l2 = ones(Int, DIM, DIM) .* 3

make_circle!(l2)

l3 = ones(Int, DIM, DIM)
for i in 11:10:DIM-10
  l3[:, i] .*= 2
end
make_circle!(l3)

CDATA_l1 = ""
for mat_id in l1
  global CDATA_l1
  CDATA_l1 *= "$mat_id"
end

CDATA_l2 = ""
for mat_id in l2
  global CDATA_l2
  CDATA_l2 *= "$mat_id"
end

CDATA_l3 = ""
for mat_id in l3
  global CDATA_l3
  CDATA_l3 *= "$mat_id"
end

output = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<VXA Version=\"1.1\">
  <Simulator>
    <Integration>
      <Integrator>0</Integrator>
      <DtFrac>0.95</DtFrac>
    </Integration>
    <Damping>
      <BondDampingZ>1.0</BondDampingZ>
      <ColDampingZ>1.0</ColDampingZ>
      <SlowDampingZ>1.0</SlowDampingZ>
    </Damping>
    <Collisions>
      <SelfColEnabled>0</SelfColEnabled>
      <ColSystem>3</ColSystem>
      <CollisionHorizon>3</CollisionHorizon>
    </Collisions>
    <Features>
      <BlendingEnabled>0</BlendingEnabled>
      <XMixRadius>0</XMixRadius>
      <YMixRadius>0</YMixRadius>
      <ZMixRadius>0</ZMixRadius>
      <BlendModel>0</BlendModel>
      <PolyExp>1</PolyExp>
      <VolumeEffectsEnabled>0</VolumeEffectsEnabled>
    </Features>
    <StopCondition>
      <StopConditionType>3</StopConditionType>
      <StopConditionValue>0.4</StopConditionValue>
    </StopCondition>
    <EquilibriumMode>
      <EquilibriumModeEnabled>0</EquilibriumModeEnabled>
    </EquilibriumMode>
  </Simulator>
  <Environment>
    <Boundary_Conditions>
      <NumBCs>0</NumBCs>
    </Boundary_Conditions>
    <Gravity>
      <GravEnabled>0</GravEnabled>
      <GravAcc>0</GravAcc>
      <FloorEnabled>0</FloorEnabled>
    </Gravity>
    <Thermal>
      <TempEnabled>1</TempEnabled>
      <TempAmplitude>1</TempAmplitude>
      <TempBase>0</TempBase>
      <VaryTempEnabled>1</VaryTempEnabled>
      <TempPeriod>400</TempPeriod>
    </Thermal>
  </Environment>
  <VXC Version=\"0.94\">
    <Lattice>
      <Lattice_Dim>0.15875</Lattice_Dim>
      <X_Dim_Adj>1</X_Dim_Adj>
      <Y_Dim_Adj>1</Y_Dim_Adj>
      <Z_Dim_Adj>1</Z_Dim_Adj>
      <X_Line_Offset>0</X_Line_Offset>
      <Y_Line_Offset>0</Y_Line_Offset>
      <X_Layer_Offset>0</X_Layer_Offset>
      <Y_Layer_Offset>0</Y_Layer_Offset>
    </Lattice>
    <Voxel>
      <Vox_Name>BOX</Vox_Name>
      <X_Squeeze>1</X_Squeeze>
      <Y_Squeeze>1</Y_Squeeze>
      <Z_Squeeze>1</Z_Squeeze>
    </Voxel>
    <Palette>
      <Material ID=\"1\">
        <MatType>0</MatType>
        <Name>Flexible</Name>
        <Display>
          <Red>0</Red>
          <Green>0</Green>
          <Blue>1</Blue>
          <Alpha>1</Alpha>
        </Display>
        <Mechanical>
          <MatModel>0</MatModel>
          <Elastic_Mod>$E_Flexible</Elastic_Mod>
          <Plastic_Mod>0</Plastic_Mod>
          <Yield_Stress>0</Yield_Stress>
          <FailModel>0</FailModel>
          <Fail_Stress>0</Fail_Stress>
          <Fail_Strain>0</Fail_Strain>
          <Density>$ρ</Density>
          <Poissons_Ratio>0.5</Poissons_Ratio>
          <CTE>0</CTE>
          <MaterialTempPhase>0</MaterialTempPhase>
          <uStatic>1</uStatic>
          <uDynamic>0.5</uDynamic>
        </Mechanical>
      </Material>
      <Material ID=\"2\">
        <MatType>0</MatType>
        <Name>Stiff</Name>
        <Display>
          <Red>1</Red>
          <Green>0</Green>
          <Blue>0</Blue>
          <Alpha>1</Alpha>
        </Display>
        <Mechanical>
          <MatModel>0</MatModel>
          <Elastic_Mod>$E_Stiff</Elastic_Mod>
          <Plastic_Mod>0</Plastic_Mod>
          <Yield_Stress>0</Yield_Stress>
          <FailModel>0</FailModel>
          <Fail_Stress>0</Fail_Stress>
          <Fail_Strain>0</Fail_Strain>
          <Density>$ρ</Density>
          <Poissons_Ratio>0.5</Poissons_Ratio>
          <CTE>0</CTE>
          <MaterialTempPhase>0</MaterialTempPhase>
          <uStatic>1</uStatic>
          <uDynamic>0.5</uDynamic>
        </Mechanical>
      </Material>
      <Material ID=\"3\">
        <MatType>0</MatType>
        <Name>Expand</Name>
        <Display>
          <Red>0</Red>
          <Green>1</Green>
          <Blue>0</Blue>
          <Alpha>1</Alpha>
        </Display>
        <Mechanical>
          <MatModel>0</MatModel>
          <Elastic_Mod>$E_Expand</Elastic_Mod>
          <Plastic_Mod>0</Plastic_Mod>
          <Yield_Stress>0</Yield_Stress>
          <FailModel>0</FailModel>
          <Fail_Stress>0</Fail_Stress>
          <Fail_Strain>0</Fail_Strain>
          <Density>$ρ</Density>
          <Poissons_Ratio>0.5</Poissons_Ratio>
          <CTE>1</CTE>
          <MaterialTempPhase>0</MaterialTempPhase>
          <uStatic>1</uStatic>
          <uDynamic>0.5</uDynamic>
        </Mechanical>
      </Material>
    </Palette>
    <Structure Compression=\"ASCII_READABLE\">
      <X_Voxels>$DIM</X_Voxels>
      <Y_Voxels>$DIM</Y_Voxels>
      <Z_Voxels>3</Z_Voxels>
      <Data>
        <Layer><![CDATA[$(CDATA_l1)]]></Layer>
        <Layer><![CDATA[$(CDATA_l2)]]></Layer>
        <Layer><![CDATA[$(CDATA_l3)]]></Layer>
      </Data>
    </Structure>
  </VXC>
</VXA>"

open("test.vxa", "w") do file
  write(file, output)
end