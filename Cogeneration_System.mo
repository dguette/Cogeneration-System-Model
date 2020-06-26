package Cogeneration_System
  package condiciones_frontera
    model frontera_fuel
      extends ThermoSysPro.Combustion.BoundaryConditions.FuelSourcePQ;
    end frontera_fuel;

    model air_in
      extends ThermoSysPro.FlueGases.BoundaryConditions.SourcePQ;
    equation

    end air_in;

    model condicion_turb
      extends ThermoSysPro.WaterSteam.BoundaryConditions.SourcePQ;
    equation

    end condicion_turb;

    model sumidero
      extends ThermoSysPro.FlueGases.BoundaryConditions.SinkP;
    equation

    end sumidero;

    model water_in
      extends ThermoSysPro.WaterSolution.BoundaryConditions.SourcePQ;
    equation

    end water_in;

    model sumidero_excha
      extends ThermoSysPro.WaterSteam.BoundaryConditions.Sink;
    equation

    end sumidero_excha;

    model condicion_balon
      extends ThermoSysPro.Thermal.BoundaryConditions.HeatSource;
    equation

    end condicion_balon;

    model condicion_flash
      extends ThermoSysPro.WaterSteam.BoundaryConditions.SinkQ;
    end condicion_flash;
  end condiciones_frontera;

  package elementos
    model Exchanger "Static heat exchanger water/steam - flue gases"
      parameter Real EffEch = 0.9 "Thermal exchange efficiency";
      parameter Real Kdpf = 10 "Pressure loss coefficient on the flue gas side";
      parameter Real Kdpe = 10 "Pressure loss coefficient on the water/steam side";
      parameter Integer mode = 0 "IF97 region of the water. 1:liquid - 2:steam - 4:saturation line - 0:automatic";
    protected
      parameter Real eps = 1.e-0 "Small number for pressure loss equation";
    public
      /*ENTRADA DE LOS GASES*/
      Modelica.SIunits.AbsolutePressure Pef(start = 3e5) "Flue gas pressure at the inlet";
      Modelica.SIunits.Temperature Tef(start = 900) "Flue gas temperature at the inlet";
      Modelica.SIunits.SpecificEnthalpy Hef(start = 1.25e6) "Flue gas specific enthalpy at the inlet";
      ThermoSysPro.FlueGases.Connectors.FlueGasesInlet Cfg1 annotation(
        Placement(transformation(extent = {{-10, 80}, {10, 100}}, rotation = 0)));
      /*SALIDA DE LOS GASES*/
      Modelica.SIunits.AbsolutePressure Psf(start = 2.5e5) "Flue gas pressure at the outlet";
      Modelica.SIunits.Temperature Tsf(start = 700) "Flue gas temperature at the outlet";
      Modelica.SIunits.SpecificEnthalpy Hsf(start = 1.25e5) "Flue gas specific enthalpy at the outlet";
      ThermoSysPro.FlueGases.Connectors.FlueGasesOutlet Cfg2 annotation(
        Placement(transformation(extent = {{-11, -100}, {10, -80}}, rotation = 0)));
      /*ENTRADA DEL AGUA/VAPOR*/
      Modelica.SIunits.AbsolutePressure Pee(start = 2e6) "Water pressure at the inlet";
      Modelica.SIunits.Temperature Tee(start = 300) "Water temperature at the inlet";
      Modelica.SIunits.SpecificEnthalpy Hee(start = 3e5) "Water specific enthalpy at the inlet";
      ThermoSysPro.WaterSteam.Connectors.FluidInlet Cws1 "Water inlet" annotation(
        Placement(transformation(extent = {{-110, -10}, {-90, 10}}, rotation = 0)));
      /*SALIDA DEL AGUA /VAPOR*/
      Modelica.SIunits.AbsolutePressure Pse(start = 2e6) "Water pressure at the outlet";
      Modelica.SIunits.Temperature Tse(start = 450) "Water temperature at the outlet";
      Modelica.SIunits.SpecificEnthalpy Hse(start = 23e5) "Water specific enthalpy at the outlet";
      ThermoSysPro.WaterSteam.Connectors.FluidOutlet Cws2 "Water outlet" annotation(
        Placement(transformation(extent = {{90, -10}, {110, 10}}, rotation = 0)));
      /*VARIABLES DE LOS GASES*/
      Modelica.SIunits.MassFlowRate Qf "Flue gas mass flow rate";
      Modelica.SIunits.Density rhof(start = 0.9) "Fluie gas density";
      Modelica.SIunits.SpecificHeatCapacity Cpf "Flue gas specific heat capacity";
      /*VARIABLES DEL AGUA/VAPOR*/
      Modelica.SIunits.MassFlowRate Qe "Water mass flow rate";
      Modelica.SIunits.Density rhoe "Water density";
      Modelica.SIunits.SpecificHeatCapacity Cpe "Water specific heat capacity";
      /*VARIABLES INTERCAMBIADOR*/
      Modelica.SIunits.TemperatureDifference DT1 "Delta T at the inlet";
      Modelica.SIunits.TemperatureDifference DT2 "Delta T at the outlet";
      Modelica.SIunits.Power W(start = 1e8) "Exchanger power";
      /*DEFINICION DE PROPIEDADES*/
      ThermoSysPro.Properties.WaterSteam.Common.ThermoProperties_ph proee annotation(
        Placement(transformation(extent = {{-100, 80}, {-80, 100}}, rotation = 0)));
      ThermoSysPro.Properties.WaterSteam.Common.ThermoProperties_ph proes annotation(
        Placement(transformation(extent = {{-60, 80}, {-40, 100}}, rotation = 0)));
      ThermoSysPro.Properties.WaterSteam.Common.ThermoProperties_ph proem annotation(
        Placement(transformation(extent = {{60, 80}, {80, 100}}, rotation = 0)));
    equation
/* Flue gas inlet */
      Pef = Cfg1.P;
      Tef = Cfg1.T;
      Qf = Cfg1.Q;
/* Flue gas outlet */
      Psf = Cfg2.P;
      Tsf = Cfg2.T;
      Qf = Cfg2.Q;
      Cfg2.Xco2 = Cfg1.Xco2;
      Cfg2.Xh2o = Cfg1.Xh2o;
      Cfg2.Xo2 = Cfg1.Xo2;
      Cfg2.Xso2 = Cfg1.Xso2;
/* Water inlet */
      Pee = Cws1.P;
      Hee = Cws1.h;
      Qe = Cws1.Q;
/* Water outlet */
      Pse = Cws2.P;
      Hse = Cws2.h;
      Qe = Cws2.Q;
/* Flow reversal */
      0 = if Qe > 0 then Cws1.h - Cws1.h_vol else Cws2.h - Cws2.h_vol;
/* Counter-current exchanger */
      DT1 = Tef - Tse;
      DT2 = Tsf - Tee;
/* Power exchanged between the hot and the cold sides */
      W = noEvent(min(Qe * Cpe, Qf * Cpf)) * EffEch * (Tef - Tee);
      W = Qf * (Hef - Hsf);
      W = Qe * (Hse - Hee);
/* Pressure losses */
      Pef = Psf + Kdpf * ThermoSysPro.Functions.ThermoSquare(Qf, eps) / rhof;
      Pee = Pse + Kdpe * ThermoSysPro.Functions.ThermoSquare(Qe, eps) / rhoe;
/* Flue gas specific enthalpy at the inlet */
      Hef = ThermoSysPro.Properties.FlueGases.FlueGases_h(Pef, Tef, Cfg1.Xco2, Cfg1.Xh2o, Cfg1.Xo2, Cfg1.Xso2);
/* Flue gas specific enthalpy at the outlet */
      Hsf = ThermoSysPro.Properties.FlueGases.FlueGases_h(Psf, Tsf, Cfg1.Xco2, Cfg1.Xh2o, Cfg1.Xo2, Cfg1.Xso2);
/* Flue gas specific heat capacity */
      Cpf = ThermoSysPro.Properties.FlueGases.FlueGases_cp(Pef, Tef, Cfg1.Xco2, Cfg1.Xh2o, Cfg1.Xo2, Cfg1.Xso2);
/* Flue gas specific density */
      rhof = ThermoSysPro.Properties.FlueGases.FlueGases_rho(Pef, Tef, Cfg1.Xco2, Cfg1.Xh2o, Cfg1.Xo2, Cfg1.Xso2);
/* Water/steam thermodynamic properties */
      proee = ThermoSysPro.Properties.WaterSteam.IF97.Water_Ph(Pee, Hee, mode);
      Tee = proee.T;
      proem = ThermoSysPro.Properties.WaterSteam.IF97.Water_Ph((Pee + Pse) / 2, (Hee + Hse) / 2, mode);
      rhoe = proem.d;
      Cpe = proee.cp;
      proes = ThermoSysPro.Properties.WaterSteam.IF97.Water_Ph(Pse, Hse, mode);
      Tse = proes.T;
      annotation(
        Diagram(graphics = {Rectangle(extent = {{-100, 50}, {100, -50}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Rectangle(extent = {{-100, -50}, {100, -80}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Backward), Rectangle(extent = {{-100, 80}, {100, 50}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Backward), Line(points = {{-94, -2}, {-44, -2}, {-24, 46}, {16, -48}, {36, -2}, {90, -2}}, color = {0, 0, 0}, thickness = 0.5), Text(extent = {{-28, 72}, {34, 56}}, lineColor = {0, 0, 0}, lineThickness = 0.5, fillPattern = FillPattern.HorizontalCylinder, fillColor = {175, 175, 175}, textString = "HotFlueGases"), Text(extent = {{-34, 8}, {42, -6}}, lineColor = {0, 0, 0}, lineThickness = 0.5, fillPattern = FillPattern.HorizontalCylinder, fillColor = {175, 175, 175}, textString = "WaterSteam"), Text(extent = {{-30, -58}, {32, -74}}, lineColor = {0, 0, 0}, lineThickness = 0.5, fillPattern = FillPattern.HorizontalCylinder, fillColor = {175, 175, 175}, textString = "HotFlueGases")}),
        Icon(graphics = {Rectangle(extent = {{-100, 80}, {100, 50}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Backward), Rectangle(extent = {{-100, 50}, {100, -50}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Line(points = {{-94, -2}, {-44, -2}, {-24, 46}, {16, -48}, {36, -2}, {90, -2}}, color = {0, 0, 0}, thickness = 0.5), Text(extent = {{-34, 8}, {42, -6}}, lineColor = {0, 0, 0}, lineThickness = 0.5, fillPattern = FillPattern.HorizontalCylinder, fillColor = {175, 175, 175}, textString = "WaterSteam"), Rectangle(extent = {{-100, -50}, {100, -80}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Backward), Text(extent = {{-30, -58}, {32, -74}}, lineColor = {0, 0, 0}, lineThickness = 0.5, fillPattern = FillPattern.HorizontalCylinder, fillColor = {175, 175, 175}, textString = "HotFlueGases"), Text(extent = {{-30, 72}, {32, 56}}, lineColor = {0, 0, 0}, lineThickness = 0.5, fillPattern = FillPattern.HorizontalCylinder, fillColor = {175, 175, 175}, textString = "HotFlueGases")}),
        Documentation(revisions = "<html>
    <u><p><b>Authors</u> : </p></b>
    <ul style='margin-top:0cm' type=disc>
    <li>
        Baligh El Hefni</li>
    </html>
    ", info = "<html>
    <p><b>Copyright &copy; EDF 2002 - 2010</b></p>
    </HTML>
    <html>
    <p><b>ThermoSysPro Version 2.0</b></p>
    </HTML>
    "));
    end Exchanger;

    model compresor_2
      parameter Real RPcomp = 31.25 "relacion de compresion";
      parameter Real Ncomp = 0.85 "eficiencia de compresion";
      parameter Real Nmec = 0.985 "eficiencia del compresor";
      Real KC;
      Real RCpv;
    public
      Modelica.SIunits.Power Wcp "Compressor power";
      Modelica.SIunits.SpecificHeatCapacity Promcp;
      Modelica.SIunits.SpecificHeatCapacity Promcv;
      Modelica.SIunits.SpecificHeatCapacity Cpe;
      Modelica.SIunits.SpecificHeatCapacity Cps;
      Modelica.SIunits.SpecificHeatCapacity Cve;
      Modelica.SIunits.SpecificHeatCapacity Cvs;
      Modelica.SIunits.AbsolutePressure Pe "Air pressure at the inlet";
      Modelica.SIunits.AbsolutePressure Ps "Air pressure at the outlet";
      Modelica.SIunits.Temperature Te "Air temperature at the inlet";
      Modelica.SIunits.Temperature Ts "Air temperature at the outlet";
      Modelica.SIunits.Temperature Tek "Air temperature at the inlet in kelvin";
      Modelica.SIunits.Temperature Tsk "Air temperature at the outlet in kelvin";
      Modelica.SIunits.SpecificEnthalpy He "Air specific enthalpy at the inlet";
      Modelica.SIunits.SpecificEnthalpy Hs "Air specific enthalpy at the outlet";
      Modelica.SIunits.MassFlowRate Q "Air mass flow rate";
    public
      ThermoSysPro.FlueGases.Connectors.FlueGasesInlet Ce annotation(
        Placement(transformation(extent = {{-100, -10}, {-80, 10}}, rotation = 0)));
      ThermoSysPro.FlueGases.Connectors.FlueGasesOutlet Cs annotation(
        Placement(transformation(extent = {{80, -10}, {100, 10}}, rotation = 0)));
    public
      ThermoSysPro.InstrumentationAndControl.Connectors.OutputReal Power annotation(
        Placement(transformation(extent = {{80, -40}, {100, -20}}, rotation = 0)));
    equation
/* Connector at the inlet */
      Pe = Ce.P;
      Q = Ce.Q;
      Te = Ce.T;
/* Connector at the outlet */
      Ps = Cs.P;
      Q = Cs.Q;
      Ts = Cs.T;
/* Flue gases composition */
      Cs.Xco2 = Ce.Xco2;
      Cs.Xh2o = Ce.Xh2o;
      Cs.Xo2 = Ce.Xo2;
      Cs.Xso2 = Ce.Xso2;
/*Presion de Salida*/
      Ps = RPcomp * Pe;
/*Temperatura de Salida*/
      Tek = Te + 273.15;
      Tsk = Ts + 273.15;
      Ts = (Te) + ((Te-273.15) / Ncomp) * (RPcomp ^ RCpv - 1);
      Cpe = ThermoSysPro.Properties.FlueGases.FlueGases_cp(Pe, Tek, Ce.Xco2, Ce.Xh2o, Ce.Xo2, Ce.Xso2);
      Cps = ThermoSysPro.Properties.FlueGases.FlueGases_cp(Pe * RPcomp, Tsk, Cs.Xco2, Cs.Xh2o, Cs.Xo2, Cs.Xso2);
      Cve = ThermoSysPro.Properties.FlueGases.FlueGases_cv(Pe, Tek, Ce.Xco2, Ce.Xh2o, Ce.Xo2, Ce.Xso2);
      Cvs = ThermoSysPro.Properties.FlueGases.FlueGases_cv(Pe * RPcomp, Tsk, Cs.Xco2, Cs.Xh2o, Cs.Xo2, Cs.Xso2);
      Promcp = (Cpe + Cps) / 2;
      Promcv = (Cve + Cvs) / 2;
      KC = Promcp / Promcv;
      RCpv = (KC - 1) / KC;
/* Compressor power */
      Wcp = Q * (Hs - He) / Nmec;
      Power.signal = Wcp;
/* Specific enthalpy at the inlet */
      He = ThermoSysPro.Properties.FlueGases.FlueGases_h(Pe, Te, Ce.Xco2, Ce.Xh2o, Ce.Xo2, Ce.Xso2);
/* Specific enthalpy at the outlet */
      Hs = ThermoSysPro.Properties.FlueGases.FlueGases_h(Pe * RPcomp, Ts, Cs.Xco2, Cs.Xh2o, Cs.Xo2, Cs.Xso2);
      annotation(
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-120, -100}, {120, 100}}, initialScale = 0.1), graphics = {Polygon( fillColor = {0, 255, 0}, fillPattern = FillPattern.Backward,points = {{-80, 80}, {-80, -80}, {80, -40}, {80, 40}, {-80, 80}})}),
        Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-120, -100}, {120, 100}}, initialScale = 0.1), graphics = {Polygon(fillColor = {103, 103, 103}, fillPattern = FillPattern.Backward,points = {{-80, 80}, {-80, -80}, {80, -40}, {80, 40}, {-80, 80}})}),
        Documentation(revisions = "<html>
    <u><p><b>Authors</u> : </p></b>
    <ul style='margin-top:0cm' type=disc>
    <li>
        Baligh El Hefni</li>
    </ul>
    </html>
    ", info = "<html>
    <p><b>Copyright &copy; EDF 2002 - 2010</b></p>
    </HTML>
    <html>
    <p><b>ThermoSysPro Version 2.0</b></p>
    </HTML>
    "));
    end compresor_2;

    model turbina_2
      parameter Real RPexp = 29 "relacion de expansion";
      parameter Real Nexp = 0.88 "eficiencia de expansion";
      parameter Real Ngen = 0.985 "eficiencia generador electrico";
      Real KC;
      Real RCpv;
    public
      Modelica.SIunits.Power Wcp "Compressor power";
      Modelica.SIunits.Power Wturb "Turbine power";
      Modelica.SIunits.Power Wnet "netanical power";
      Modelica.SIunits.Power Pelec "netanical power";
      Modelica.SIunits.SpecificHeatCapacity Promcp;
      Modelica.SIunits.SpecificHeatCapacity Promcv;
      Modelica.SIunits.SpecificHeatCapacity Cpe;
      Modelica.SIunits.SpecificHeatCapacity Cps;
      Modelica.SIunits.SpecificHeatCapacity Cve;
      Modelica.SIunits.SpecificHeatCapacity Cvs;
      Modelica.SIunits.AbsolutePressure Pe "Air pressure at the inlet";
      Modelica.SIunits.AbsolutePressure Ps "Air pressure at the outlet";
      Modelica.SIunits.Temperature Te "Air temperature at the inlet";
      Modelica.SIunits.Temperature Ts "Air temperature at the outlet";
      Modelica.SIunits.Temperature Tek "Air temperature at the inlet in kelvin";
      Modelica.SIunits.Temperature Tsk "Air temperature at the outlet in kelvin";
      Modelica.SIunits.SpecificEnthalpy He "Air specific enthalpy at the inlet";
      Modelica.SIunits.SpecificEnthalpy Hs "Air specific enthalpy at the outlet";
      Modelica.SIunits.MassFlowRate Q "Air mass flow rate";
    public
      ThermoSysPro.FlueGases.Connectors.FlueGasesInlet Ce annotation(
        Placement(transformation(extent = {{-110, -10}, {-90, 10}}, rotation = 0)));
      ThermoSysPro.FlueGases.Connectors.FlueGasesOutlet Cs annotation(
        Placement(transformation(extent = {{90, -10}, {110, 10}}, rotation = 0)));
    public
      ThermoSysPro.InstrumentationAndControl.Connectors.InputReal CompressorPower annotation(
        Placement(transformation(extent = {{-120, -50}, {-100, -30}}, rotation = 0)));
    public
      ThermoSysPro.InstrumentationAndControl.Connectors.OutputReal netPower annotation(
        Placement(transformation(extent = {{100, -100}, {120, -80}}, rotation = 0)));
    equation
/* Connector at the inlet */
      Pe = Ce.P;
      Q = Ce.Q;
      Te = Ce.T;
/* Connector at the outlet */
      Ps = Cs.P;
      Q = Cs.Q;
      Ts = Cs.T;
/* Input compressor power (negative value) */
      Wcp = CompressorPower.signal;
/* Flue gases composition */
      Cs.Xco2 = Ce.Xco2;
      Cs.Xh2o = Ce.Xh2o;
      Cs.Xo2 = Ce.Xo2;
      Cs.Xso2 = Ce.Xso2;
/*Temperatura de Salida*/
      Ts = Te - Te * Nexp * (1 - (1 - (1 / RPexp) ^ RCpv));
      KC = Promcp / Promcv;
      RCpv = (KC - 1) / KC;
      Promcp = (Cpe + Cps) / 2;
      Promcv = (Cve + Cvs) / 2;
      Tek = Te + 273.15;
      Tsk = Ts + 273.15;
      Cpe = ThermoSysPro.Properties.FlueGases.FlueGases_cp(Pe, Tek, Ce.Xco2, Ce.Xh2o, Ce.Xo2, Ce.Xso2);
      Cps = ThermoSysPro.Properties.FlueGases.FlueGases_cp(Pe / RPexp, Tsk, Cs.Xco2, Cs.Xh2o, Cs.Xo2, Cs.Xso2);
      Cve = ThermoSysPro.Properties.FlueGases.FlueGases_cv(Pe, Tek, Ce.Xco2, Ce.Xh2o, Ce.Xo2, Ce.Xso2);
      Cvs = ThermoSysPro.Properties.FlueGases.FlueGases_cv(Pe / RPexp, Tsk, Cs.Xco2, Cs.Xh2o, Cs.Xo2, Cs.Xso2);
/* Turbine power */
      Wturb = Q * (He - Hs);
      Wnet = Wturb - Wcp;
      Pelec = Wnet * Ngen;
      netPower.signal = Wnet;
/* Specific enthalpy at the inlet */
      He = ThermoSysPro.Properties.FlueGases.FlueGases_h(Pe, Te, Ce.Xco2, Ce.Xh2o, Ce.Xo2, Ce.Xso2);
/* Specific enthalpy at the outlet */
      Hs = ThermoSysPro.Properties.FlueGases.FlueGases_h(Pe / RPexp, Ts, Cs.Xco2, Cs.Xh2o, Cs.Xo2, Cs.Xso2);
      annotation(
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-150, -150}, {150, 150}}, initialScale = 0.1), graphics = {Polygon( lineColor = {0, 0, 255}, fillColor = {128, 255, 0}, fillPattern = FillPattern.Backward,points = {{-100, 40}, {-100, -40}, {100, -100}, {100, 100}, {-100, 40}})}),
        Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-150, -150}, {150, 150}}, initialScale = 0.1), graphics = {Polygon(lineColor = {0, 0, 255}, fillColor = {97, 97, 97}, fillPattern = FillPattern.Backward, points = {{-100, 40}, {-100, -40}, {100, -100}, {100, 100}, {-100, 40}})}),
        Documentation(revisions = "<html>
    <u><p><b>Authors</u> : </p></b>
    <ul style='margin-top:0cm' type=disc>
    <li>
        Baligh El Hefni</li>
    </ul>
    </html>
    ", info = "<html>
    <p><b>Copyright &copy; EDF 2002 - 2010</b></p>
    </HTML>
    <html>
    <p><b>ThermoSysPro Version 2.0</b></p>
    </HTML>
    "));
    end turbina_2;

    model camara_2
      extends ThermoSysPro.Combustion.CombustionChambers.GTCombustionChamber;
    equation

    end camara_2;

    model Turbina_Gas2
      parameter Real RPcomp = 20.1 "relacion de compresion";
      parameter Real Ncomp = 0.85 "eficiencia de compresion";
      parameter Real Nmec = 0.98 "eficiencia del comrpesor";
      parameter Real RPexp = 9.2 "relacion de expansion";
      parameter Real Nexp = 0.88 "eficiencia de expansion";
      parameter Real Ngen = 0.98 "eficiencia generador electrico";
      ThermoSysPro.FlueGases.BoundaryConditions.AirHumidity xAIR annotation(
        Placement(visible = true, transformation(origin = {-50, 30}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
      ThermoSysPro.FlueGases.Connectors.FlueGasesInletI Entree_air annotation(
        Placement(transformation(extent = {{-104, -4}, {-96, 4}}, rotation = 0)));
      ThermoSysPro.FlueGases.Connectors.FlueGasesOutletI Sortie_fumees annotation(
        Placement(transformation(extent = {{96, -4}, {104, 4}}, rotation = 0)));
      ThermoSysPro.WaterSteam.Connectors.FluidInletI Entree_eau_combustion annotation(
        Placement(transformation(extent = {{-64, 96}, {-56, 104}}, rotation = 0)));
      ThermoSysPro.Combustion.Connectors.FuelInletI Entree_combustible annotation(
        Placement(transformation(extent = {{56, 96}, {64, 104}}, rotation = 0)));
      ThermoSysPro.InstrumentationAndControl.Connectors.InputReal Huminide annotation(
        Placement(transformation(extent = {{-108, 56}, {-100, 64}}, rotation = 0)));
      ThermoSysPro.InstrumentationAndControl.Connectors.OutputReal PuissanceMeca annotation(
        Placement(transformation(extent = {{100, -44}, {108, -36}}, rotation = 0)));
      Cogeneration_System.elementos.compresor_2 compresor annotation(
        Placement(visible = true, transformation(origin = {-20, -1.77636e-15}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
      Cogeneration_System.elementos.turbina_2 turbina annotation(
        Placement(visible = true, transformation(origin = {59, -2.10942e-15}, extent = {{-19, -20}, {19, 20}}, rotation = 0)));
      /*Cogeneration_System.elementos.camara_2 camara_combustion*/
      ThermoSysPro.Combustion.CombustionChambers.GTCombustionChamber camara_combustion annotation(
        Placement(visible = true, transformation(origin = {20, 40}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
    equation
      connect(Entree_air, xAIR.C1) annotation(
        Line(points = {{-100, 0}, {-68, 0}, {-68, 40}, {-50, 40}, {-50, 40}}));
      connect(Huminide, xAIR.humidity) annotation(
        Line(points = {{-104, 60}, {-38, 60}, {-38, 30}, {-38, 30}}, color = {0, 0, 255}));
      connect(xAIR.C2, compresor.Ce) annotation(
        Line(points = {{-50, 20}, {-50, 20}, {-50, 0}, {-36, 0}, {-36, 0}}));
      connect(turbina.netPower, PuissanceMeca) annotation(
        Line(points = {{80, -18}, {80, -18}, {80, -40}, {104, -40}, {104, -40}}, color = {0, 0, 255}));
      connect(turbina.Cs, Sortie_fumees) annotation(
        Line(points = {{78, 0}, {100, 0}, {100, 0}, {100, 0}}));
      connect(compresor.Power, turbina.CompressorPower) annotation(
        Line(points = {{-4, -6}, {20, -6}, {20, -8}, {38, -8}, {38, -8}}, color = {0, 0, 255}));
      connect(camara_combustion.Cfg, turbina.Ce) annotation(
        Line(points = {{38, 40}, {38, 40}, {38, 0}, {40, 0}}));
      connect(compresor.Cs, camara_combustion.Ca) annotation(
        Line(points = {{-4, 0}, {2, 0}, {2, 40}, {2, 40}}));
      connect(camara_combustion.Cfuel, Entree_combustible) annotation(
        Line(points = {{20, 22}, {60, 22}, {60, 100}, {60, 100}, {60, 100}}));
      connect(camara_combustion.Cws, Entree_eau_combustion) annotation(
        Line(points = {{8, 58}, {8, 58}, {8, 80}, {-60, 80}, {-60, 100}, {-60, 100}}, color = {0, 0, 255}));
      annotation(
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}, initialScale = 0.1), graphics),
        Icon(coordinateSystem(preserveAspectRatio = false, initialScale = 0.1), graphics = {Polygon(fillColor = {75, 75, 75}, fillPattern = FillPattern.Solid, points = {{-100, 72}, {-100, -70}, {-20, -20}, {-20, 20}, {-100, 72}}), Rectangle(fillColor = {43, 43, 43}, fillPattern = FillPattern.Solid, extent = {{-20, 20}, {20, -20}}), Polygon(fillColor = {40, 40, 40}, fillPattern = FillPattern.Solid, points = {{20, 20}, {20, -20}, {100, -70}, {100, 70}, {20, 20}}), Line(points = {{-60, 96}, {-60, 60}, {-10, 60}, {-10, 20}}, color = {0, 0, 255}), Line(points = {{60, 96}, {60, 60}, {8, 60}, {8, 20}}, color = {0, 0, 127})}),
        Documentation(revisions = "<html>
    <u><p><b>Authors</u> : </p></b>
    <ul style='margin-top:0cm' type=disc>
    <li>
        Baligh El Hefni</li>
    </html>
    ", info = "<html>
    <p><b>Copyright &copy; EDF 2002 - 2010</b></p>
    </HTML>
    <html>
    <p><b>ThermoSysPro Version 2.0</b></p>
    </HTML>
    "));
    end Turbina_Gas2;
  end elementos;

  package control
    block humedad
      extends ThermoSysPro.InstrumentationAndControl.Blocks.Sources.Constante;
    end humedad;

    block rampaIQaire
      extends ThermoSysPro.InstrumentationAndControl.Blocks.Sources.Rampe;
    end rampaIQaire;
  end control;

  model test_TurbinaGas2
    Cogeneration_System.elementos.Turbina_Gas2 Turbina_Gas annotation(
      Placement(visible = true, transformation(origin = {3.55271e-15, 0}, extent = {{-40, -40}, {40, 40}}, rotation = 0)));
    condiciones_frontera.air_in aire_entrada(P0 = 101300, Q0 = 85.35, T0 = 288.15, Xco2 = 0.0037, Xo2 = 0.205) annotation(
      Placement(visible = true, transformation(origin = {-80, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    condiciones_frontera.condicion_turb agua_vapor(Q0 = 0) annotation(
      Placement(visible = true, transformation(origin = {-80, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    condiciones_frontera.frontera_fuel fuel_entrada(Cp = 49440, LHV = 48446e3, P0 = 3.4e+06, Q0 = 1.85, T0 = 359.85, Xc = 0.761, Xh = 0.239, rho = 0.737) annotation(
      Placement(visible = true, transformation(origin = {0, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    Cogeneration_System.condiciones_frontera.sumidero sumi(P0 = 220000) annotation(
      Placement(visible = true, transformation(origin = {94, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    Cogeneration_System.control.humedad humedad_aire(k = 0.60) annotation(
      Placement(visible = true, transformation(origin = {-78, 20}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
    control.rampaIQaire rampa_fuel(Duration = 10, Finalvalue = 2.45, Initialvalue = 1.85, Starttime = 5) annotation(
      Placement(visible = true, transformation(origin = {-68, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    Cogeneration_System.condiciones_frontera.condicion_turb auga(P0 = 200000, Q0 = 80, h0 = 106000) annotation(
      Placement(visible = true, transformation(origin = {94, -20}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
    Cogeneration_System.condiciones_frontera.sumidero_excha sumi_exchanger annotation(
      Placement(visible = true, transformation(origin = {96, 24}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    Cogeneration_System.elementos.Exchanger sobrecalentador2 annotation(
      Placement(visible = true, transformation(origin = {64, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  equation
    connect(aire_entrada.C, Turbina_Gas.Entree_air) annotation(
      Line(points = {{-70, 0}, {-40, 0}, {-40, 0}, {-40, 0}}));
    connect(agua_vapor.C, Turbina_Gas.Entree_eau_combustion) annotation(
      Line(points = {{-70, 40}, {-24, 40}, {-24, 40}, {-24, 40}}, color = {0, 0, 255}));
    connect(fuel_entrada.C, Turbina_Gas.Entree_combustible) annotation(
      Line(points = {{10, 60}, {24, 60}, {24, 40}, {24, 40}}));
    connect(humedad_aire.y, Turbina_Gas.Huminide) annotation(
      Line(points = {{-69, 20}, {-56, 20}, {-56, 24}, {-42, 24}}, color = {0, 0, 255}));
    connect(rampa_fuel.y, fuel_entrada.IMassFlow) annotation(
      Line(points = {{-56, 70}, {0, 70}, {0, 66}, {0, 66}}, color = {0, 0, 255}));
    connect(Turbina_Gas.Sortie_fumees, sobrecalentador2.Cfg1) annotation(
      Line(points = {{40, 0}, {54, 0}, {54, 0}, {54, 0}}));
    connect(sobrecalentador2.Cfg2, sumi.C) annotation(
      Line(points = {{74, 0}, {84, 0}, {84, 0}, {84, 0}}));
    connect(auga.C, sobrecalentador2.Cws1) annotation(
      Line(points = {{84, -20}, {64, -20}, {64, -10}, {64, -10}}, color = {0, 0, 255}));
    connect(sobrecalentador2.Cws2, sumi_exchanger.C) annotation(
      Line(points = {{64, 10}, {64, 10}, {64, 24}, {86, 24}, {86, 24}}, color = {0, 0, 255}));
  end test_TurbinaGas2;

  model Systema_2
    Cogeneration_System.condiciones_frontera.frontera_fuel fuel_in(Cp = 3022, LHV = 48446e3, P0 = 3.4e+06, Q0 = 1.85, T0(displayUnit = "K") = 360, Xn = 0.03, Xo = 0.01, rho = 0.737) annotation(
      Placement(visible = true, transformation(origin = {-60, 80}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
    Cogeneration_System.condiciones_frontera.air_in air_in(P0 = 101300, T0(displayUnit = "degC"), Xh2o = 0, Xso2 = 0) annotation(
      Placement(visible = true, transformation(origin = {-200, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
    Cogeneration_System.control.humedad hume(k = 0.6) annotation(
      Placement(visible = true, transformation(origin = {-210, 34}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    Cogeneration_System.condiciones_frontera.sumidero sumi(P0 = 220000) annotation(
      Placement(visible = true, transformation(origin = {380, 1.77636e-15}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
    Cogeneration_System.elementos.Exchanger sobrecalentador2(EffEch = 0.9, Kdpe = 5, Kdpf = 5, Pef(start = 300000)) annotation(
      Placement(visible = true, transformation(origin = {60, 1.77636e-15}, extent = {{20, -20}, {-20, 20}}, rotation = 90)));
    Cogeneration_System.condiciones_frontera.condicion_turb agua_alimentacion(P0 = 1.52e+06, Q0 = 63, h0 = 106000) annotation(
      Placement(visible = true, transformation(origin = {380, -40}, extent = {{20, -20}, {-20, 20}}, rotation = 0)));
    Cogeneration_System.elementos.Exchanger sobrecalentador1(EffEch = 0.9, Kdpe = 5, Kdpf = 5) annotation(
      Placement(visible = true, transformation(origin = {140, 0}, extent = {{20, -20}, {-20, 20}}, rotation = 90)));
    Cogeneration_System.elementos.Exchanger economizador(EffEch = 0.9, Kdpe = 5, Kdpf = 5) annotation(
      Placement(visible = true, transformation(origin = {300, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 90)));
    Cogeneration_System.condiciones_frontera.condicion_turb cond_turbina(Q0 = 0) annotation(
      Placement(visible = true, transformation(origin = {-150, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    Cogeneration_System.condiciones_frontera.sumidero_excha sumi_exchanger annotation(
      Placement(visible = true, transformation(origin = {380, -80}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
    Cogeneration_System.elementos.Turbina_Gas2 turbina annotation(
      Placement(visible = true, transformation(origin = {-60, -7.10543e-15}, extent = {{-60, -60}, {60, 60}}, rotation = 0)));
    Cogeneration_System.control.rampaIQaire rampa_fuel(Duration = 60, Finalvalue = 2.95, Initialvalue = 1.85, Starttime = 0) annotation(
      Placement(visible = true, transformation(origin = {-120, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    Cogeneration_System.elementos.Exchanger evaporador annotation(
      Placement(visible = true, transformation(origin = {220, -1.77636e-15}, extent = {{-20, -20}, {20, 20}}, rotation = 90)));
    Real N_ther;
    Real HR;
    Real SFC;
    Real N_cog;
    Cogeneration_System.control.rampaIQaire rampa_aire(Duration = 60, Finalvalue = 76.5, Initialvalue = 86.5, Starttime = 0) annotation(
      Placement(visible = true, transformation(origin = {-270, 10}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    control.rampaIQaire rampa_temp(Duration = 60, Finalvalue = 305.15, Initialvalue = 278.15, Starttime = 0) annotation(
      Placement(visible = true, transformation(origin = {-270, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  equation
    connect(economizador.Cfg2, sumi.C) annotation(
      Line(points = {{318, 0}, {360, 0}}));
    connect(sobrecalentador2.Cfg2, sobrecalentador1.Cfg1) annotation(
      Line(points = {{78, 0}, {122, 0}}));
    connect(sobrecalentador2.Cws2, sumi_exchanger.C) annotation(
      Line(points = {{60, -20}, {60, -80}, {360, -80}}, color = {0, 0, 255}));
    connect(turbina.Sortie_fumees, sobrecalentador2.Cfg1) annotation(
      Line(points = {{0, 0}, {44, 0}, {44, 0}, {42, 0}}));
    connect(fuel_in.C, turbina.Entree_combustible) annotation(
      Line(points = {{-40, 80}, {-24, 80}, {-24, 60}, {-24, 60}}));
    connect(cond_turbina.C, turbina.Entree_eau_combustion) annotation(
      Line(points = {{-140, 60}, {-96, 60}, {-96, 60}, {-96, 60}}, color = {0, 0, 255}));
    connect(air_in.C, turbina.Entree_air) annotation(
      Line(points = {{-180, 0}, {-120, 0}}));
    connect(hume.y, turbina.Huminide) annotation(
      Line(points = {{-199, 34}, {-124, 34}, {-124, 36}, {-122, 36}}, color = {0, 0, 255}));
    connect(sobrecalentador1.Cfg2, evaporador.Cfg1) annotation(
      Line(points = {{158, 0}, {202, 0}, {202, 0}, {202, 0}}));
    connect(evaporador.Cfg2, economizador.Cfg1) annotation(
      Line(points = {{238, 0}, {282, 0}}));
    connect(economizador.Cws1, agua_alimentacion.C) annotation(
      Line(points = {{300, -20}, {300, -20}, {300, -40}, {360, -40}, {360, -40}}, color = {0, 0, 255}));
    connect(sobrecalentador2.Cws1, sobrecalentador1.Cws2) annotation(
      Line(points = {{60, 20}, {60, 20}, {60, 40}, {100, 40}, {100, -40}, {140, -40}, {140, -20}, {140, -20}}, color = {0, 0, 255}));
    connect(sobrecalentador1.Cws1, evaporador.Cws2) annotation(
      Line(points = {{140, 20}, {140, 20}, {140, 40}, {220, 40}, {220, 20}, {220, 20}}, color = {0, 0, 255}));
    connect(evaporador.Cws1, economizador.Cws2) annotation(
      Line(points = {{220, -20}, {220, -20}, {220, -40}, {260, -40}, {260, 40}, {300, 40}, {300, 20}, {300, 20}}, color = {0, 0, 255}));
    N_ther = (Cogeneration_System.Systema_2.turbina.turbina.Pelec) / Cogeneration_System.Systema_2.turbina.camara_combustion.Wfuel;
    HR = (3600*48446*Cogeneration_System.Systema_2.turbina.Entree_combustible.Q) / (Cogeneration_System.Systema_2.turbina.turbina.Pelec/1000);
    SFC = (1.3*3600 * Cogeneration_System.Systema_2.turbina.Entree_combustible.Q) / (Cogeneration_System.Systema_2.turbina.turbina.Pelec/1000);
    N_cog = (Cogeneration_System.Systema_2.turbina.turbina.Pelec + Cogeneration_System.Systema_2.economizador.W + Cogeneration_System.Systema_2.evaporador.W + Cogeneration_System.Systema_2.sobrecalentador1.W + Cogeneration_System.Systema_2.sobrecalentador2.W) / (3600*48446*Cogeneration_System.Systema_2.turbina.Entree_combustible.Q);
    connect(rampa_temp.y, air_in.ITemperature) annotation(
      Line(points = {{-258, -30}, {-200, -30}, {-200, -10}, {-200, -10}}, color = {0, 0, 255}));
    connect(rampa_aire.y, air_in.IMassFlow) annotation(
      Line(points = {{-258, 10}, {-200, 10}, {-200, 10}, {-200, 10}}, color = {0, 0, 255}));
  protected
    annotation(
      Diagram(coordinateSystem(extent = {{-300, -200}, {400, 200}})),
      Icon(coordinateSystem(extent = {{-300, -200}, {400, 200}})));
  end Systema_2;
  annotation(
    uses(ThermoSysPro(version = "3.1")));
end Cogeneration_System;
