# FeatureExtraction_SafetyMetrics_SafetyMetricsClass

<!--
*** The following documentation is based on the Best-README-Template.
*** To avoid retyping too much info. Do a search and replace for the following:
*** github_username, repo_name, twitter_handle, email, project_title, project_description
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links


[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

-->

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <!-- <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

  <h3 align="center">FeatureExtraction_SafetyMetrics_SafetyMetricsClass</h3>

  <p align="center">
    MATLAB code implementation of functions that perform safety metric calculations given a set of objects and a path through them.
    <br />
    <a href="https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/tree/main/Documents">View Demo</a>
    ·
    <a href="https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/issues">Report Bug</a>
    ·
    <a href="https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/issues">Request Feature</a>
  </p>
</p>


<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li>
      <a href="#repo-structure">Repo Structure</a>
      <ul>
        <li><a href="#top-level-directories">Top-Level Directories</a></li>
        <li><a href="#dependencies">Dependencies</a></li>
      </ul>
    </li>
    <li>
    <a href="#functions">Functions</a>
    <ul>
        <li>
        <a href="#point-set-association-functions">Point-Set Association Functions</a>
         <ul>
         <li><a href="#fcn_points_plotsetsxy">fcn_Points_plotSetsXY</a></li>
          <li><a href="#fcn_points_fillpointsamplesets">fcn_Points_fillPointSampleSets</a></li>
          <li><a href="#fcn_points_fillpointsetviauserinputs">fcn_Points_fillPointSetViaUserInputs</a></li>
          <li><a href="#fcn_points_adjustpointsetstatistics">fcn_Points_adjustPointSetStatistics</a></li>
          <li><a href="#fcn_points_addradialnoise">fcn_Points_addRadialNoise</a></li>
          <li><a href="#fcn_points_calcpairstatistics">fcn_Points_calcPairStatistics</a></li>
          <li><a href="#fcn_points_pairxydata">fcn_Points_pairXYdata</a></li>
          <li><a href="#script_associatepointsincremental">script_AssociatePointsIncremental</a></li>
        </ul>
        </li>
		<li>
        <a href="#safety-metrics-functions">Safety Metrics Functions</a>
         <ul>
         <li><a href="#fcn_safetymetrics_create_vehicletraj">fcn_SafetyMetrics_create_vehicleTraj</a></li>
          <li><a href="#fcn_safetymetrics_plottrajectoryxy">fcn_SafetyMetrics_plotTrajectoryXY</a></li>
          <li><a href="#fcn_safetymetrics_add_and_plot_object">fcn_SafetyMetrics_add_and_plot_object</a></li>
          <li><a href="#fcn_safetymetrics_unit_vector">fcn_SafetyMetrics_unit_vector</a></li>
          <li><a href="#fcn_safetymetrics_plot_2d_vehicle">fcn_SafetyMetrics_plot_2D_vehicle</a></li>
          <li><a href="#fcn_safetymetrics_plot_3d_vehicle">fcn_SafetyMetrics_plot_3D_vehicle</a></li>
        </ul>
        </li>
		<li>
        <a href="#laps-functions">Laps Functions</a>
         <ul>
         <li><a href="#fcn_laps_plotlapsxy">fcn_Laps_plotLapsXY</a></li>
          <li><a href="#fcn_laps_plotpointzonedefinition">fcn_Laps_plotPointZoneDefinition</a></li>
          <li><a href="#fcn_laps_plotsegmentzonedefinition">fcn_Laps_plotSegmentZoneDefinition</a></li>
          <li><a href="#fcn_laps_plotzonedefinition">fcn_Laps_plotZoneDefinition</a></li>
          <li><a href="#fcn_laps_findpointzonestartstopandminimum">fcn_Laps_findPointZoneStartStopAndMinimum</a></li>
          <li><a href="#fcn_laps_breakdataintolaps">fcn_Laps_breakDataIntoLaps</a></li>
        </ul>
        </li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
	<li><a href="#hypothesis-metrics">Hypothesis Metrics</a></li>
	<ul>
	<li><a href="#surrogate-safety-metrics">Surrogate safety metrics</a></li>
	<ul>
	<li><a href="#time-to-collision-ttc">Time to collision (TTC)</a></li>
	<li><a href="#post-encroachment-time">Post encroachment time</a></li>
	<li><a href="#deceleration-rate-to-avoid-crash">Deceleration rate to avoid crash</a></li>
	<li><a href="#speed-differential">Speed differential</a></li>
	<li><a href="#conflict-severity-index">Conflict severity index</a></li>
	<li><a href="#relative-lane-position">Relative lane position</a></li>
	<li><a href="#time-to-lane-departure">Time to lane departure</a></li>
	</ul>
	<li><a href="#obstacle-avoidance-measures">Obstacle avoidance measures</a></li>
	<ul>
	<li><a href="#mimimum-clearance-distance-over-all-objects">Mimimum clearance distance over all objects</a></li>
	<li><a href="#smallest-clearance-to-each-object-category">Smallest clearance to each object category</a></li>
	<li><a href="#if-impact-relative-velocity-at-impact">If impact, relative velocity at impact</a></li>
	<li><a href="#if-impact-location-of-impact-on-the-vehicle">If impact, location of impact on the vehicle</a></li>
	<li><a href="#if-impact-location-of-impact-on-object">If impact, location of  impact on object</a></li>
	</ul>
	<li><a href="#compliance-with-traffic-laws-and-speed-limit-compliance">Compliance with traffic laws and speed limit compliance</a></li>
	<ul>
	<li><a href="#point-speed">Point speed</a></li>
	<li><a href="#posted-speed-disparity">Posted speed disparity</a></li>
	<li><a href="#throughput">Throughput</a></li>
	<li><a href="#stopping-point-stopping-time-or-rolling-stop-minimum-speedlocation">Stopping point, stopping time, or rolling-stop minimum speed/location</a></li>
	<li><a href="#density">Density</a></li>
	</ul>
	<li><a href="#consistency-of-vehicle-flow-in-a-work-zone-remains-the-same">Consistency of vehicle flow in a work zone remains the same</a></li>
	<ul>
	<li><a href="#consistency-measures">Consistency Measures</a></li>
	<ul>
	<li><a href="#av-point-speed">AV point speed</a></li>
	<li><a href="#av-lane-choice">AV lane choice</a></li>
	<li><a href="#av-site-specific-speed-disparity">AV site-specific speed disparity</a></li>
	<li><a href="#av-follower-specific-speed-disparity">AV follower-specific speed disparity</a></li>
	<li><a href="#av-leader-specific-speed-disparity">AV leader-specific speed disparity</a></li>
	<li><a href="#spacing-between-the-av-and-a-lead-vehicle">Spacing between the AV and a lead vehicle</a></li>
	<li><a href="#spacing-between-the-av-and-a-follow-vehicle">Spacing between the AV and a follow vehicle</a></li>
	<li><a href="#av-relative-land-position">AV relative land position</a></li>
	<li><a href="#av-total-acceleration-vector">AV total acceleration vector</a></li>
	</ul>
	<li><a href="#external-vehicle-measures">External Vehicle Measures</a></li>
	<ul>
	<li><a href="#throughput-evm">Throughput EVM</a></li>
	<li><a href="#density-evm">Density EVM</a></li>
	</ul>
	</ul>
	</ul>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>


<!-- ABOUT THE PROJECT -->
## About The Project

<!--[![Product Name Screen Shot][product-screenshot]](https://example.com)-->

MATLAB code implementation of functions that perform safety metric calculations given a set of objects and a path through them. These codes were originally developed to support the PennDOT ADS project in order to assess and compare "safety" of vehicles traversing an environment with obstacles, lane markers, etc.

NOTE: This code is still in development (alpha testing)!

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass.git
   ```

2. Create the utilities directories

    This code depends on the following repos

    * [Errata_Tutorials_DebugTools](https://github.com/ivsg-psu/Errata_Tutorials_DebugTools) - The DebugTools repo is used for the initial automated folder setup, and for input checking and general debugging calls within subfunctions. The repo can be found at: https://github.com/ivsg-psu/Errata_Tutorials_DebugTools

    * [PathPlanning_PathTools_PathClassLibrary](https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary) - the PathClassLibrary contains tools used to find intersections of the data with particular line segments, which is used to find start/end/excursion locations in the functions. The repo can be found at: https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary

    Each should be installed in a folder called "Utilities" under the root folder, namely ./Utilities/DebugTools/ , ./Utilities/PathClassLibrary/ 

    If you wish to put these codes in different directories, the main call stack in script_demo_Laps can be easily modified with strings specifying the different location, but the user will have to make these edits directly.

    For ease of getting started, the zip files of the directories used - without the .git repo information, to keep them small - are included in this repo.


3. Check compatibility
    * Make sure to run MATLAB 2020b or higher (the "digitspattern" command used in the DebugTools was released then).

4. Run the code
    * Run script_demo_Laps from the working directory root location
    * If the code works, the script should run without errors producing numerous example images and results. As well, AFTER running this main script, the other scripts within the ./Functions folder should also work.

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***
<!-- STRUCTURE OF THE REPO -->
## Repo Structure
All scripts start with "script_" and all functions start with "fcn_".

The main demo script is at the root directory. Running this script should initialize the directory structure, and thus it should always be run first. It will also illustrate key features in the code. Additional code details are found in the function scripts.

Functions specifically developed for this repo are in the /Functions directory. Each function has associated with it a test script.

Supporting utilities (not edited in this repo, and supported in other repos) are in the utilities directory. 

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Top-Level Directories
The following are the top level directories within the repository:
<ul>
	<li>Documents: Descriptions of the functionality and usage of the various MATLAB functions and scripts in the repository.</li>
	<li>Functions: The majority of the code for this repo can be found in this directory. All functions as well as test scripts are provided.</li>
	<li>Utilities: Dependencies that are utilized but not implemented in this repository are placed in the Utilities directory. These can be single files but are most often other cloned repositories kept as a zip file, with the git details stripped out to keep the zip small.</li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Dependencies

* [Errata_Tutorials_DebugTools](https://github.com/ivsg-psu/Errata_Tutorials_DebugTools) - The DebugTools repo is used for the initial automated folder setup, and for input checking and general debugging calls within subfunctions. The repo can be found at: <https://github.com/ivsg-psu/Errata_Tutorials_DebugTools>

* [PathClass_v2023_02_01](https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary/blob/main/Releases/PathClass_v2023_02_01.zip?raw=true) - The PathClass repo is used for plotting lane markers and trajectory. The repo can be found at: <https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary/blob/main/Releases/PathClass_v2023_02_01.zip?raw=true>

The dependencies are automatically installed by running the root master script

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

<!-- FUNCTION DEFINITIONS -->
## Functions

### Point-Set Association Functions
<ul>
	<li>fcn_Points_checkInputsToFunctions: TEMPLATE function for checking arguments to functions, such as point sets, etc. to make sure the formatting and sizes are correct</li>
	<li>fcn_Points_fillPointSampleSets: a function to load some sample data sets to use for testing the other functions</li>
	<li>fcn_Points_fillPointSetViaUserInputs: a function that allows a user to create (X,Y) point sets by clicking in a figure with the mouse</li>
	<li>fcn_Points_plotSetsXY: a function that plots (X,Y) point sets with various options</li>
	<li>fcn_Points_pairXYdata: a function that associates the mutually closest points in two different point sets and returns the pairs as well as points which don't have an obvious mutual pair, in both directions</li>
	<li>fcn_Points_calcPairStatistics: a function that calculates the statistics for paired sets of points, returning RMS deviation, variance in point locations, and the offset between the centroids of the two point sets (a measurement of the systematic "shift" between two point sets)</li>
	<li>fcn_Points_adjustPointSetStatistics: a function to add 2D Gaussian noise and/or bias to a point set (e.g. to simulate sensor noise or bias) </li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Patch Object Creation/Manipulation Functions
<ul>
	<li>fcn_Patch_fillSamplePatches: a function to load a few sample patch objects of different sizes, shapes, and colors for testing the other patch object functions</li>
	<li>fcn_Patch_fillPatchArrayViaUserInputs: a function that allows a user to create patch objects by choosing patch colors and then using a mouse to click in a figure window to define the vertices of the patch object</li>
	<li>fcn_Patch_plotPatch: a function that plots patch a patch object or an array of patch objects, optionally choosing particular patch objects from the array and/or plotting into a particular figure</li>
	<li>fcn_Patch_insertPoints: a function that allows the user to insert one or more (X,Y) points into a patch object to add vertices to the patch object</li>
	<li>fcn_Patch_determineAABB: a function to determine the (X,Y) extremes of the patch object and store them in the patch object attributes</li>
	<li>fcn_Patch_inferPrimitive: a function to test the fit of circular and rectangular shape primitives to the vertices of the patch object and store the best fit to the patch object attributes (or reject both fits and label the object as irregular)</li>
	<li>fcn_Patch_checkCollisions: a function to test an array of patch objects to determine impact point and time or, for non-collisions, the closest point and time of closest approach with a rectangular object traveling in a circular trajectory of a given radius, center point, and initial heading</li>
</ul>
Each of the functions has an associated test script, using the convention
	```sh
	script_test_fcn_fcnname
	```
where fcnname is the function name starting with "Patch" or "Point" as listed above.

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Safety Metrics Functions

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_SafetyMetrics_create_vehicleTraj

This code will plot a vehicle trajectory given the x,y,and angle.

FORMAT: 
```MATLAB
    [time,xtotal,ytotal,yaw,flag_object] = fcn_SafetyMetrics_create_vehicleTraj(traj_type,traj_plot,varargin)
```
**INPUTS:**

traj_type: a number 1 - 5 representing which trajectory is wanted
<ul>
<li>1: Lane change </li>
<li>2: Stop at stop sign</li>
<li>3: Half-lane change around an object</li>
<li>4: Right hand turn</li>
<li>5: Left hand turn</li>
</ul>
traj_plot: a boolean value if simple plotting is wanted. 1 = plot

**OUTPUTS:**

time: 500x1 matrix of time

xtotal: 500x1 matrix of x coordinates

ytotal: 500x1 matrix of y coordinates

yaw: 500x1 matrix of yaw angles for each xy point

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_SafetyMetrics_plotTrajectoryXY

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_SafetyMetrics_add_and_plot_object

This code will plot an object at the position given.

FORMAT: 
```MATLAB
fcn_SafetyMetrics_add_and_plot_object(time,object_vertices,object_type,varargin)
```
**INPUTS:**

time: a nx1 matrix of all the times.

object_vertices: a 2xn matix continaing the vertices of a polytope x
and y data.

object_type: a number with the number being the type of
plot, one per time step or cylindar(3d object).

<ul>
1: a 2d object plotted at each time step

2: a cylindar(or 3d object) with a radius specified by FWHA and height equal to time length
</ul>
(optional inputs)

fig_num: any number that acts somewhat like a figure number output.
If given, this forces the variable types to be displayed as output
and as well makes the input check process verbose.

**OUTPUTS:**


<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_SafetyMetrics_unit_vector

This code will caculate the unit vector of the the vehicle along a
trajectory in space time.

FORMAT: 
```MATLAB 
fcn_SafetyMetrics_unit_vector(trajectory, vehicle_param, varargin)
```
**INPUTS:**

trajectory: [time,x,y,yaw_angle] 4x1 vector

**OUTPUTS:**

u: a matrix with the unit vectors of the trajectory. [time,x,y]

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_SafetyMetrics_plot_2D_vehicle

This code will plot a vehicle given the x,y,and angle.

FORMAT: 
```MATLAB 
fcn_plot_2D_vehicle(vehicle_position,vehicle_param,time_interval,varargin)
```
**INPUTS:**

vehicle_position: [time,x,y,yaw_angle] 4x1 vector

vehicle_param: sturcture containing 
<ul>

a: distnace from origin to front axel (positive)

b: distnace form origin to rear axel (positive)

Lf:Length from origin to front bumper

Lr:Length from origin to rear bumper

w_tire_tire: width from center of tire to center of tire

w_vehicle:width form outer most left side to outer most right side

tire_width: width of one tire

tire_length: diameter of one tire

</ul>

(optional inputs)

fig_num: any number that acts somewhat like a figure number output. 
If given, this forces the variable types to be displayed as output 
and as well makes the input check process verbose.

**OUTPUTS:**



<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_SafetyMetrics_plot_3D_vehicle

This code will plot a vehicle given the x,y,t and angle.

FORMAT: 
```MATLAB 
fcn_SafetyMetrics_plot_3D_vehicle(vehicle_position,vehicle_param,varargin)
```
**INPUTS:**

vehicle_position: [time,x,y,yaw_angle] 4x1 vector

vehicle_param: sturcture containing 
<ul>

a: distnace from origin to front axel (positive)

b: distnace form origin to rear axel (positive)

Lf:Length from origin to front bumper

Lr:Length from origin to rear bumper

w_tire_tire: width from center of tire to center of tire

w_vehicle:width form outer most left side to outer most right side

tire_width: width of one tire

tire_length: diameter of one tire

</ul>

(optional inputs)

plot_style: matlab input plotting style such as 'b-'

fig_num: any number that acts somewhat like a figure number output. 
If given, this forces the variable types to be displayed as output 
and as well makes the input check process verbose.

**OUTPUTS:**


<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Laps Functions

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_Laps_plotLapsXY

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_Laps_plotPointZoneDefinition

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_Laps_plotSegmentZoneDefinition

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_Laps_plotZoneDefinition

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_Laps_findPointZoneStartStopAndMinimum

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### fcn_Laps_breakDataIntoLaps

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

<!-- USAGE EXAMPLES -->
## Usage
<!-- Use this space to show useful examples of how a project can be used.
Additional screenshots, code examples and demos work well in this space. You may
also link to more resources. -->

1. Open MATLAB and navigate to the Functions directory

2. Run any of the various test scripts, such as
   ```sh
   script_test_fcn_Points_pairXYdata
   ```
   or
   ```sh
   script_test_fcn_Patch_checkCollisions
   ```
_For more examples, please refer to the [Documentation] 

https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/tree/main/Documents)_

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

<!-- Metrics -->
## Hypothesis Metrics
Metrics are arranged by the PEP
### Surrogate safety metrics

#### Time to collision (TTC)

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![Diagram of Time to collision](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/TTC.png)

</li>
	<li> Description: The time from when an entity leaves a specific location (or conflict point) to the time another entity arrives at that location. </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Post encroachment time

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: The time from when an entity leaves a specific location (or conflict point) to the time another entity arrives at that location.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Deceleration rate to avoid crash

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: The minimum required deceleration rate a vehicle must apply to avoid a crash if the paths and speeds of all other entities are maintained.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Speed differential

<ul>
	<li> Function name: </li>
	<li> Diagram:
	
![Diagram of Speed differential](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Speed_differntal.png)
	
</li>
	<li> Description: The difference in speed between a vehicle and a conflicting entity at the time/point of collision.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Conflict severity index

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: related to ratio of TTC^2 and perception-reaction time^2. This is a normalized value between 0 and 1, where 1 is the most severe conflict and 0 is the least severe.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Relative lane position

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: The location of the vehicle with respect to the lane edge and centerline. Note that this metric generally cannot be obtained from a microsimulation but can be obtained from the simulation of the AV. This metric can also be computed from real data.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Time to lane departure

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: : The time until the vehicle would depart the lane given its current trajectory. Note that this metric generally cannot be obtained from a microsimulation but can be obtained from the simulation of the AV. This metric can also be computed from real data.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Obstacle avoidance measures

#### Mimimum clearance distance over all objects

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: This is calculated by determining, at each time point in a trajectory, the minimum radial distance between the closest boundary of the vehicle and an object that would result in a collision. The intent of this distance is to quantify, at each time point, possible near-misses of vehicles to surrounding objects where surrounding objects are perimeter-defined via either the AV’s sensor “map,” the mapping van-generated map, or instrumentation on the objects within the work zone to measure object positions. </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Smallest clearance to each object category

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: This is the same metric described previously, but also captured relative to different object types present in the near-range vicinity (e.g., sensor range) of the vehicle. The purpose of collecting this metric is that the severity of near-missing a cone is minor, whereas near-missing a pedestrian is of grave concern. The object categories expected, in approximate order of severity from least severe to most severe, might include the following: cones, barrels, barriers, roadside signs, poles, parked vehicles/equipment, moving work zone vehicles/equipment, and pedestrians.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### If impact, relative velocity at impact

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: This is a metric that assumes a collision takes place, useful to estimate how much energy would be transferred from the vehicle to a roadside object.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### If impact, location of impact on the vehicle

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![Diagram of If impact, location of impact on the vehicle](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/if_impact_location.png)
	
</li>
	<li> Description: This is a metric of the location that the impact would first take place, as measured in vehicle body-fixed coordinates. The purpose of this metric is to determine whether portions of the vehicle would either be damaged (for example, key sensors the AV needs to continue moving) or if the vehicle impact location might have mitigated the impact in some manner, such as an instance where a foldable mirror were the only point of contact.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### If impact, location of  impact on object

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![Diagram of If impact, location of impact on object](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/if_impact_location_object.png)

</li>
	<li> Description: This is a metric of the location that the impact would first take place, as measured in object’s body-fixed coordinates (assuming centroid of the object as the coordinate origin). The purpose of this metric is to determine what portions of the object would be damaged (i.e., signage) or if the vehicle impact location might have mitigated due to the object in some manner, such as if the “impact” was a vehicle tire riding up onto an A-type barrier—mitigating any damage to the vehicle and/or barrier.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Compliance with traffic laws and speed limit compliance

#### Point speed

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![Point Speed](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Point_speed.png)
	
</li>
	<li> Description: Speed of individual vehicle at a given location along the roadway.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Posted speed disparity

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![Point Speed Disparity](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Posted_speed_disparity.png)	
	
</li>
	<li> Description: Speed of vehicle relative to posted speed limit, with positive values being over-speed conditions, negative values being under-speed conditions.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Throughput 

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: The rate at which vehicles can clear the area of interest (at the downstream end) per unit time. This is used to evaluate anomalous behaviors that can result in safety concerns such as severe grouping of vehicles.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Stopping point, stopping time, or rolling-stop minimum speed/location

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![ Diagram of Stopping point, stopping time, or rolling-stop minimum speed/location](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Stopping_point.png)	
	
</li>
	<li> Description: This metric is provided in the situation that a stopping device or traffic light is indicated in the work zone.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Density

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: : Spatial rate of vehicles within the area of interest (vehicles per unit length). This is used to evaluate anomalous behaviors that can result in safety concerns.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Consistency of vehicle flow in a work zone remains the same

#### Consistency measures

##### AV point speed

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![ Diagram of AV point speed](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/AV_point_speed.png)	
	
</li>
	<li> Description: Speed of individual vehicle at a given location along the roadway.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### AV lane choice

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: The lane the AV chooses to use, if multiple lanes are available.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### AV site-specific speed disparity

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![ Diagram of AV site-specifc speed disparity](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/AV_leader_specific_speed_disparity.png)			

</li>
	<li> Description: The speed disparity of the AV relative to average vehicle (assuming human-driven, averaged over a long duration) at that station of the work zone. A positive disparity means the AV is faster than average; negative is less than average.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### AV follower-specific speed disparity

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![ Diagram of AV follower-specific speed disparity](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/AV_follower_specific_speed_disparity.png)		

</li>
	<li> Description: The speed disparity of the AV relative to the vehicle ahead, if any are within sensor range, at that station of the work zone.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### AV leader-specific speed disparity 

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![ Diagram of AV follower-specific speed disparity](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/AV_leader_specific_speed_disparity.png)		
	
</li>
	<li> Description: The speed disparity of the AV relative to the vehicle behind, if any are within sensor range, at that station of the work zone.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### Spacing between the AV and a lead vehicle

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![ Diagram of Spacing between the AV and a lead vehicle](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Spacing_Between_the_AV_and_lead.png)	
	
</li>
	<li> Description: : Like the TTC metric for safety, this is a metric of the distance between the AV and the nearest vehicle ahead within sensor range. </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### Spacing between the AV and a follow vehicle

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![ Diagram of Spacing between the AV and a follow vehicle](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Spacing_between_the_AV_follow.png)	
	
</li>
	<li> Description: Like the TTC metric for safety for the follower vehicle, this is a metric of the distance between the AV and the nearest vehicle behind the AV, looking at whether the AV appears to cause other vehicles behind to “tailgate” the AV.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### AV relative land position

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: The location of the vehicle with respect to the lane edge and centerline. Note that this metric generally cannot be obtained from a traffic microsimulation but can be obtained from the simulation of the AV in more advanced vehicle simulation tools or can also be computed from real-world data.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### AV total acceleration vector

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: This is the vector of the acceleration measured at the center-of-gravity (CG) of the vehicle, used to determine cornering, braking, and tractive forces. This is particularly useful to determine friction utilization of the AV at different locations within the work zone, and thus the remaining maneuvering envelope. For example, if the AV is measured with 0.5 g of lateral acceleration and the skid number of the pavement indicates a friction supply of 0.5 (e.g., a Skid Number of approximately 50), then this case indicates that the AV would not be able to swerve further to avoid work zone vehicles or pedestrians without skidding.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

#### External Vehicle measures

##### Throughput EVM

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: Rate vehicles can clear the area of interest (at the downstream end). This is used to evaluate anomalous behaviors that can result in safety concerns.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### Density EVM

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: Spatial rate of vehicles within the area of interest (vehicles per unit length). This is used to evaluate anomalous behaviors that can result in safety concerns.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Imporoved recognition of work zone boundaries

#### Logitidunial metrics: Binary

##### Presence or absence of workzone

<ul>
	<li> Function name: </li>
	<li> Diagram: 

![ Diagram of Presence or absence of workzone](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Presence_or_absene_work_zone.png)
	
</li>
	<li> Description: This is a binary flag, either 1 or 0, at each time point indicating whether an AV interprets that it is within a work zone.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>


#### Longitudinal metrics: Continous

##### S-coordinate vector from AV declaration of boundary to actual work zone boundary.

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### S-coordinate vector from AV detection of a work zone object to actual work zone boundary.

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### Tranverse coordinate vector from lane center of first work zone object detected by AV

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### S-coordinate vector from first complete AV communication reception of work zone data packet to actual work zone boundary, assuming a maximum vehicle speed throught that raod way

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### S-coordinate vector from the start of AV communication reception of work zone data packet to actual work zone boundary, assuming a maximum vehicle speed through that roadway

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### Right lateral-boundary disparity vector

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: This is the difference in location, measured to the right, between the AV-provided data defining interpreted work zone boundaries vs. the denoted boundaries within the map. This vector is measured relative to the mapped work zone boundary as the origin, with positive values pointing inward, namely that a positive value indicates that the AV interprets the boundary to be farther into the work zone than the map indicates.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

##### Left lateral-boundary disparity vector

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: This is the difference in location, measured to the left, for the metric described previously.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Lateral metrics: Binary

#### Binary confirmation of object presence

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: This is a binary 1 or 0 indicating agreement between AV-provided data showing objects detected, that these agree with those defined on the map.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Connectivity is robust enough for data sharing, even in a typical work zone

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Connectivity will improve AV function

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Datagram definitions for V2X are suited for work zone map sharing


#### Binary flags indication data field usage

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Work-zone-specific coating can impove object recognition by AVs

#### Range of first dection (in meters)

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![ Diagram of Range of first dection (in meters)](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/range_of_first_detection.png)	
	
</li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Incidence angle of detection, measured in degrees of any flat objects (e.g., signs), relative to the incidence angel to the vehicle's sensor

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Projected area of the object in square meters ( the cross-sectional area of the object)

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Dimensions (height, width, and geometirc configuration such as shape, profile, etc.) of the object

<ul>
	<li> Function name: </li>
	<li> Diagram: 
	
![ Diagram of Dimensions (height, width, and geometirc configuration such as shape, profile, etc.) of the object](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Dimensions_of_object.png)	
	
</li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Coating pattern, namely striping, type and direction of stripes, etc

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Wear condition, which is the subjective evaluation of wear of the object as assessed by DOT personnel equivalent to deployment assessment (e.g., “new,” “normal wear,” or “out of service wear”)

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Object detection accuracy, the classification accuracy of the object according to the AV and/or mapping van sensor data workflow.

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: </li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Work-zone-specific coating will not change human-driving vehicle behavior

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Work-zone-specific coating can improve work zone recognition by AVs

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Enhanced coatings will improve AV safety

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Enhanced mapping will improve AV safety

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

### Enchanced mapping will reduce AV data errors


#### Object detection accuracy

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: Where possible, the classification accuracy of the object according to the AV and/or mapping van sensor data workflow will be determined by comparing AV object labeling, position information, etc., to that of the mapping van, instrumented RSE, instrumented pedestrians, etc.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

#### Object prediction accuracy

<ul>
	<li> Function name: </li>
	<li> Diagram: </li>
	<li> Description: For objects that have trajectories and are instrumented (for example, instrumented work zone worker vests), the AV-predicted path projections will be compared to the resulting path projections for small look-ahead intervals. The goal is to determine whether the errors decrease. This will be considered for 0.5-, 1.0-, 2.0-, and 4.0-second look-ahead predictions.</li>
	<li> Methodology: </li>
	<li> Example results: </li>
</ul>

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***

## Space time graphs

### Lane change
![Lane Change](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Lane_change_3d.png)	
### Stopping at Stop sign
![Stopping at Stop sing](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Stop_sign_3d.png)
### Half-lane change with object
![Half-lane change with object](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Half_turn_object_3d.png)
### Right turn
![Right turn](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Right_turn_3d.png)
### Left turn
![Left turn](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass/blob/main/Images/Left_turn.png)

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***
<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***



<!-- CONTACT -->
## Contact
Prof. Sean Brennan - sbrennan@psu.edu 

Project Link: [https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass](https://github.com/ivsg-psu/FeatureExtraction_SafetyMetrics_SafetyMetricsClass)

<a href="#featureextraction_safetymetrics_safetymetricsclass">Back to top</a>

***



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[contributors-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[forks-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/network/members
[stars-shield]: https://img.shields.io/github/stars/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[stars-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/stargazers
[issues-shield]: https://img.shields.io/github/issues/ivsg-psu/reFeatureExtraction_Association_PointToPointAssociationpo.svg?style=for-the-badge
[issues-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/issues
[license-shield]: https://img.shields.io/github/license/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[license-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/blob/master/LICENSE.txt








