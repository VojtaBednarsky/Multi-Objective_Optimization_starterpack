'# MWS Version: Version 2023.5 - Jun 08 2023 - ACIS 32.0.1 -

'# length = mm
'# frequency = GHz
'# time = s
'# frequency range: fmin = 2.000000 fmax = 15.000000
'# created = '[VERSION]2023.5|32.0.1|20230608[/VERSION]


'@ Set Units

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Units
.Geometry "mm"
.Frequency "GHz"
.Time "S"
.TemperatureUnit "Kelvin"
.Voltage "V"
.Current "A"
.Resistance "Ohm"
.Conductance "Siemens"
.Capacitance "PikoF"
.Inductance "NanoH"
End With

'@ SetFrequency

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
Solver.FrequencyRange "1.000000", "10.000000"

'@ define boundaries

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Boundary
.Xmin "expanded open"
.Xmax "expanded open"
.Ymin "expanded open"
.Ymax "expanded open"
.Zmin "expanded open"
.Zmax "expanded open"
End With

'@ Set Background Material

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Material
.Type "Normal
.Colour "0.6", "0.6", "0.6"
.Epsilon "1"
.Mu "1"
.ChangeBackgroundMaterial
End With

'@ change solver type

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
ChangeSolverType "HF Time Domain"

'@ define material: dielectric

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Material
.Reset
.Name "dielectric"
.Type "Normal"
.Epsilon "4"
.Mue "1"
.TanD "0"
.TanDFreq "0.0"
.TanDGiven "False"
.TanDModel "ConstTanD"
.Sigma "0"
.TanDM "0"
.TanDMFreq "0.0"
.TanDMGiven "False"
.TanDMModel "ConstTanD"
.SigmaM "0"
.Colour "0.800000", "0.100000", "0.000000"
.Create
End With

'@ define brick: component1:substrate

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Brick
.Reset
.Name "substrate"
.Component "component1"
.Material "dielectric"
.XRange "0", "W"
.YRange "0", "L"
.ZRange "0", "h_sub"
.Create
End With

'@ define brick: component1:trace

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Brick
.Reset
.Name "trace"
.Component "component1"
.Material "PEC"
.XRange "nwcop", "wcop"
.YRange "0", "Lt"
.ZRange "h_sub", "h_sub"
.Create
End With

'@ define cylinder:component1:round

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Cylinder
.Reset
.Name "round"
.Component "component1"
.Material "PEC"
.OuterRadius "x"
.InnerRadius "0"
.Axis "z"
.Zrange "h_sub", "h_sub"
.Xcenter "W2"
.Ycenter "scyl"
.Segments "0"
.Create
End With

'@ define cylinder:component1:space

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Cylinder
.Reset
.Name "space"
.Component "component1"
.Material "Vacuum"
.OuterRadius "Rr"
.InnerRadius "0"
.Axis "z"
.Zrange "h_sub", "h_sub"
.Xcenter "W2"
.Ycenter "siner"
.Segments "0"
.Create
End With

'@ define cylinder:component1:notch

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Cylinder
.Reset
.Name "notch"
.Component "component1"
.Material "PEC"
.OuterRadius "R"
.InnerRadius "0"
.Axis "z"
.Zrange "h_sub", "h_sub"
.Xcenter "W2"
.Ycenter "sr"
.Segments "0"
.Create
End With

'@ Boolean Insert Shapes:component1:round,component1:space

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
Solid.Insert "component1:round", "component1:space"

'@ Boolean Insert Shapes:component1:trace,component1:space

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
Solid.Insert "component1:trace", "component1:space"

'@ define brick: component1:GND_up

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Brick
.Reset
.Name "GND_up"
.Component "component1"
.Material "PEC"
.XRange "0", "W"
.YRange "0", "G"
.ZRange "0", "0"
.Create
End With

'@ define waveguide port: 1

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Port
.Reset
.PortNumber "1"
.Label ""
.Folder ""
.NumberOfModes "1"
.AdjustPolarization "False"
.PolarizationAngle "0.0"
.ReferencePlaneDistance "0"
.TextSize "50"
.TextMaxLimit "1"
.Coordinates "Free"
.Orientation "ymin"
.PortOnBound "False"
.ClipPickedPortToBound "False"
.Xrange "nport", "pport"
.Yrange "0", "L"
.Zrange "0", "hport"
.XrangeAdd "0.0", "0.0"
.YrangeAdd "0.0", "0.0"
.ZrangeAdd "0.0", "0.0"
.SingleEnded "False"
.WaveguideMonitor "False"
.Create
End With

'@ SetFrequency

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
Solver.FrequencyRange "2.000000", "15.000000"

'@ define field monitor: farfield (f=5.5)

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Monitor
.Reset
.Name "farfield (f=5.5)"
.Dimension "Volume"
.Domain "Frequency"
.FieldType "farfield"
.Frequency "5.500000"
.UseSubVolume "False"
.Create
End With

'@ set PBA version

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
Discretizer.PBAVersion "2023060823"

'@ define field monitor: farfield (f=5.5)

'[VERSION]2023.5|32.0.1|20230608[/VERSION]
With Monitor
.Reset
.Name "farfield (f=5.5)"
.Dimension "Volume"
.Domain "Frequency"
.FieldType "farfield"
.Frequency "5.500000"
.UseSubVolume "False"
.Create
End With

