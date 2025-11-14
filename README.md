
# PathPlanning_GridFreePathPlanners_VGraph

<!--
The following template is based on:
Best-README-Template
Search for this, and you will find!
>
<!-- PROJECT LOGO -->
<br />
<p align="center">
  <!-- <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

  <h2 align="center"> PathPlanning_GridFreePathPlanners_VGraph
  </h2>

  <pre align="center">
    <img src=".\Images\PathPlanning_GridFreePathPlanners_VGraph.jpg" alt="main VGraph picture" width="960" height="540">
    <!--figcaption>Fig.1 - The typical progression of map generation.</figcaption -->
    <font size="-2">Photo by <a href="https://unsplash.com/@choys_?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Conny Schneider</a> on <a href="https://unsplash.com/photos/a-blue-background-with-lines-and-dots-xuTJZ7uD7PI?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
      </font>

  </pre>

  <p align="center">
    This repo contains the MATLAB functions to calculate the visibility graph of a map defined by a set of polytope vertices. The purpose of the Visibility Graph, or VGraph, code repo is to calculate the "visibility" of one point to another given a map containing polytopes. A "to" point is visible "from" another point if the line connecting the points does not pass through a polytope. The visibility graph is a core input for grid-free path planning.
    <br />
    <!-- a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/tree/main/Documents">View Demo</a>
    <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/issues">Report Bug</a>
    <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/issues">Request Feature</a -->
  </p>
</p>

***

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About the Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="structure">Repo Structure</a>
      <ul>
        <li><a href="#directories">Top-Level Directories</li>
        <li><a href="#dependencies">Dependencies</li>
      </ul>
    </li>
    <li><a href="#functions">Functions</li>
      <ul>
        <li><a href="#basic-support-functions">Basic Support Functions</li>
        <ul>
          <li><a href="#fcn_vgraph_plotvgraph">fcn_VGraph_plotVGraph - Plotting utility for showing visibilty graph</li>
          <li><a href="#fcn_vgraph_polytopesgenerateallptstable">fcn_VGraph_polytopesGenerateAllPtsTable - turn polytope verticies, as well as user-defined startXY and finishXY, into an Nx5 table of pointsWithData of the form used by visibility calculations and path planners.</li>
          <li><a href="#fcn_vgraph_calculatepointsonlines">fcn_VGraph_calculatePointsOnLines - Checks if points are on polytope boundary lines, within a tolerance</li>
          <li><a href="#fcn_vgraph_convertpolytopetodedupedpoints">fcn_VGraph_convertPolytopetoDedupedPoints - associated duplicated points shared between polytopes to their respective polytopes</li>
          <li><a href="#fcn_vgraph_findedgeweights">fcn_VGraph_findEdgeWeights -calculates vGraph edge weights using minimum of connected polytope costs (INCOMPLETE) </li>
          <li><a href="#fcn_vgraph_selfblockedpoints">fcn_VGraph_selfBlockedPoints - determines the points blocked by the obstacle containint testPointData (INCOMPLETE) </li>
          <li><a href="#fcn_vgraph_polytopepointsinpolytopes">fcn_VGraph_polytopePointsInPolytopes - checks if start or finish point(s) are within polytopes </li>
        </ul>
        <li><a href="#core-functions">Core Functions</li>
        <ul>
          <li><a href="#fcn_vgraph_clearandblockedpoints">fcn_VGraph_clearAndBlockedPoints - Calculates visibility from one point to many other points in a polytope map</li>
          <li><a href="#fcn_vgraph_clearandblockedpointsglobal">fcn_VGraph_clearAndBlockedPointsGlobal - Given a list of all start/end points within a map, calculates visibility matrix by calling fcn_VGraph_clearAndBlockedPoints repeatedly</li>
          <li><a href="#fcn_vgraph_addobstacle">fcn_VGraph_addObstacle - Calculates visibility graph update if an obstacle is added</li>
          <li><a href="#fcn_vgraph_removeobstacle">fcn_VGraph_removeObstacle  - Calculates visibility graph update if an obstacle is removed</li>
          <li><a href="#fcn_vgraph_generatedilationrobustnessmatrix">fcn_VGraph_generateDilationRobustnessMatrix  - Estimates edge clearances around each edge in a visibility matrix/li>
        </ul>
      </ul>
    <li><a href="#usage">Usage</a></li>
     <ul>
     <li><a href="#general-usage">General Usage</li>
     <li><a href="#examples">Examples</li>
     </ul>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

***

<!-- ABOUT THE PROJECT -->
## About The Project

<!--[![Product Name Screen Shot][product-screenshot]](https://example.com)-->

The purpose of the Visibility Graph repo is to calculate the visbility of one point to another and host functions that support this calculation.

* Inputs:
  * a map given by an array of polytopes that may be convex or non-convex
  * the start, end, and optional excursion points can also be specified
* Outputs
  * the visibility graph matrix, which represents the from (rows) and to (columns) with a value of 0 meaning not visible, 1 being visible

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Installation

1. Make sure to run MATLAB 2020b or higher. Why? The "digitspattern" command used in the DebugTools utilities was released late 2020 and this is used heavily in the Debug routines. If debugging is shut off, then earlier MATLAB versions will likely work, and this has been tested back to 2018 releases.

2. Clone the repo. The easiest way to do this is to use the GitHub desktop application. The direct git command is:

   ```sh
   git clone https://github.com/ivsg-psu/PathPlanning_GridFreePathPlanners_VGraph
   ```

3. Run the main code in the root of the folder (script_demo_VGraph.m), this will download the required utilities for this code, unzip the zip files into a Utilities folder (.\Utilities), and update the MATLAB path to include the Utility locations. This install process will only occur the first time. Note: to force the install to occur again, there is a "flag" section near the top of the script that uses a 1==0 or 1==1 to deactivate or activate a fresh install. 
4. Confirm it works! Run script_demo_VGraph. If the code works, the script should run without errors. This script produces numerous example images such as those in this README file.

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

<!-- STRUCTURE OF THE REPO -->
### Directories

The following are the top level directories within the repository:
<ul>
 <li>/Documents folder: Descriptions of the functionality and usage of the various MATLAB functions and scripts in the repository.</li>
 <li>/Functions folder: The majority of the code for the point and patch association functionalities are implemented in this directory. All functions as well as test scripts are provided.</li>
 <li>/Data folder: This is the location where example data is stored.</li>
 <li>/Utilities folder: Dependencies that are utilized but not implemented in this repository are placed in the Utilities directory. These can be single files but are most often folders containing other cloned repositories.</li>
</ul>

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

### Dependencies

* [Errata_Tutorials_DebugTools](https://github.com/ivsg-psu/Errata_Tutorials_DebugTools) - The DebugTools repo is used for the initial automated folder setup, and for input checking and general debugging calls within subfunctions. The repo can be found at: <https://github.com/ivsg-psu/Errata_Tutorials_DebugTools>

* [PathPlanning_MapTools_MapGenClassLibrary](https://github.com/ivsg-psu/PathPlanning_MapTools_MapGenClassLibrary) - The MapGenClass repo is used to create polytope-defined maps representing open space and keep-out areas. The repo can be found at: <https://github.com/ivsg-psu/PathPlanning_MapTools_MapGenClassLibrary>

* [PathPlanning_PathTools_PathClassLibrary](https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary) - the PathClassLibrary contains tools used to find intersections of visibility lines with polytope edges. The repo can be found at: <https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary>

* [FieldDataCollection_VisualizingFieldData_PlotRoad](https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotRoad) - the PlotRoad library contains advanced plotting tools such as color layering. The repo can be found at: <https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotRoad>

Note that the main demo script uses an Installer function that automatically updates the codes for each dependency above to their respective latest versions.

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

<!-- FUNCTION DEFINITIONS -->
## Functions

### Basic Support Functions

#### fcn_VGraph_plotVGraph

The function fcn_VGraph_plotVGraph plots a visibility graph given a generated vgraph and list of all points.
It allows user to specify the plot styleString and optional from/to indices
of the vertices to plot. It also includes an animation option to show the VGraph being generated.

 **FORMAT:**

```Matlab
% FORMAT:
%
% fcn_VGraph_plotVGraph(vGraph, pointsWithData,  styleString, (selectedFromToIndices), (figNum))
%
% INPUTS:
%
%    vGraph: the visibility graph as an nxn matrix where n is the number of points (nodes) in the map.
%    A 1 is in position i,j if point j is visible from point i.  0 otherwise.
%
%    pointsWithData: the nx5 list of all points in the space to be searched, with
%    the exception of the start and finish, with columns containing the
%    following information
%       x-coordinate
%       y-coordinate
%       point id number
%       obstacle id number (-1 if none)
%       is beginning/end of obstacle (1 if beginning, 2 if end, 0 if neither)
%    Usually, the last 2 points are the start and end points respectively,
%    and they have an obstacle ID number of -1. Start has an is-beginning
%    value of 1, the end has a value of 2.
%
%    styleString: string of format '-g' indicating the line style to be
%    used when plotting the visibility graph
%
% (OPTIONAL INPUTS)
%
%    selectedFromToIndices: default is [] (empty) which plots all to/from
%    combinations. If user enters a 1x1 integer, the integer is taken to be
%    the index number to plot the "from" index range. If entered as a 1x2
%    vector, the first value is the "from" index, the second value is the
%    "to" index.
%
%    saveFile: a string specifying the file where an animated GIF is saved.
%
%    figNum: a figure number to plot results. If set to -1, skips any
%    input checking or debugging, uses current figure for plotting, and
%    sets up code to maximize speed.
%
% OUTPUTS:
%
%    h_plot: a handle to the plot handle
  ```

<pre align="center">
  <img src=".\Images\fcn_VGraph_plotVGraph.png" alt="fcn_VGraph_plotVGraph picture" width="400" height="300">
  <img src=".\Images\fcn_VGraph_plotVGraph_selectedFrom.png" alt="fcn_VGraph_plotVGraph_selectedFrom picture" width="400" height="300">
  <img src=".\Images\fcn_VGraph_plotVGraph_selectedFromTo.png" alt="fcn_VGraph_plotVGraph_selectedFromTo picture" width="400" height="300">
  <img src=".\Images\fcn_VGraph_plotVGraph.gif" alt="fcn_VGraph_plotVGraph animation" width="400" height="300">
  <figcaption>Fig.1 - The function fcn_VGraph_plotVGraph plots the visibility graph (top), selected "from" portions of the visibility graph (second from top), selected to/from portions of the graph (second from bottom), or creation of animated gifs (bottom).</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

#### fcn_VGraph_polytopesGenerateAllPtsTable

A short function to turn polytope verticies, as well as user-defined
start and finish vertices, into an Nx5 table of pointsWithData of the
form used by visibility calculations and path planners.

The intent in creating this pointsWithData list is to avoid repeatedly
looping through polytopes to check collisions. Note that visibility
calculations must distinguish between points that are on the same
polytope versus those that are not - for example, two points on the same
obstacle may be visible to each other if adjacent, but not if their
connectivity passes "through" the obstacle. This list of points, for each
point, includes also the the obstacle ID number (or number of the
polytope). As well, some calculations for polytopes must consider if the
point starts or ends a looping around the perimeter of the polytope. Such
points that start or end a "loop" must also be tagged accordingly. In
summary, the following information is needed: the point location (XY),
the unique numbering of the point (e.g. "point 8"), the numbering
associated with the polytope/obstacle to which the point belongs (e.g.
"obstacle 3", or in the case of "pure" points that have no associated
obstacle (start and end for example), "obstacle -1". And finally, each
point must be tagged whether the point starts (1) or ends (2) the
perimeter of the obstacle (or is a start or end point, respectively).

The function allows start/end points to be added or omitted. If the
user only gives polytopes, then the vertices of the polytopes are
returned in matrix form. If the user gives the start and/or finish
points, these points are appended to the polytope vertex list with index
N+1 and N+2 respectively (for start and finish) where N is the number of
vertices inside the polytope field.

 **FORMAT:**

```Matlab
% FORMAT:
% [pointsWithData, startPointData, finishPointData] = ...
%     fcn_VGraph_polytopesGenerateAllPtsTable( ...
%     polytopes, ....
%     (startXY), (finishXY), (figNum))
%
% INPUTS:
%
%     polytopes: the polytope struct array
%
%     (optional inputs)
%
%     startXY: the start point vector (x,y)
%
%     finishXY: the finish point vector (x,y)
%
%     figNum: a figure number to plot results. If set to -1, skips any
%     input checking or debugging, no figures will be generated, and sets
%     up code to maximize speed. As well, if given, this forces the
%     variable types to be displayed as output and as well makes the input
%     check process verbose
%
% OUTPUTS:
%
%     pointsWithData: p-by-5 matrix of all the possible origination points for
%     visibility calculations including the vertex points on each obstacle,
%     and if the user specifies, the start and/or end points. If the
%     start/end points are omitted, the value of p is the same as the
%     number of points within the polytope field, numPolytopeVertices.
%     Otherwise, p is 1 or 2 larger depending on whether start/end is
%     given.
%
%    The information in the 5 columns is as follows:
%         x-coordinate
%         y-coordinate
%         point id number
%         obstacle id number (-1 for start/end points)
%         beginning/ending indication (1 if the point is a beginning or
%         start point, 2 if ending point or finish point, and 0 otherwise)
%         Ex: [x y point_id obs_id beg_end]
%
%     startPointData: the start point vector as a 1x5 array with the same
%     information as pointsWithData. Returns empty if user does not
%     specify.
%
%     finishPointData: the finish point vector  as a 1x5 array with the same
%     information as pointsWithData. Returns empty if user does not
%     specify.
  ```

<pre align="center">
  <img src=".\Images\fcn_VGraph_polytopesGenerateAllPtsTable.png" alt="fcn_VGraph_polytopesGenerateAllPtsTable picture" width="400" height="300">
  <figcaption>Fig.1 - The function fcn_VGraph_polytopesGenerateAllPtsTable associates each vertex point with a unique numbered index, with an associated polytope, and with either a start or finish location on or off a polytope.</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

#### fcn_VGraph_calculatePointsOnLines

fcn_VGraph_calculatePointsOnLines is a vectorized (fast) method to
determine whether the points are on lines between point set 1 and point
set 2. This is NOT an exact calculation (see the Path library for this)
but is useful because of its speed. The function allows a tolerance band
around the line, aligned with the axes, that determine if a point is on
or not on a given line segment.

 **FORMAT:**

```Matlab
% FORMAT:
%
%  flagIsOnLine = fcn_VGraph_calculatePointsOnLines(X1,Y1,X2,Y2,XI,YI,ACC)
%
% INPUTS:
%
% x1: x values for the polytope
%
% y1: y values for the polytope
%
% x2: x values from X1 with the first value moved to the end
%
% y2: y values from Y1 with the first value moved to the end
%
% xi: the x values for the points of interest
%
% yi: the y values for the points of interest
%
% tolerance: variable for determining how close to the line the point of
% interest must be to be considered "on" the line (tolerance accounts for
% calculation rounding)
%
% (optional inputs)
%
% figNum: a figure number to plot results. If set to -1, skips any
% input checking or debugging, no figures will be generated, and sets
% up code to maximize speed. As well, if given, this forces the
% variable types to be displayed as output and as well makes the input
% check process verbose
%
% OUTPUTS:
%
% flagIsOnLine: n-by-m vector of True(1) or False(0) values determining
% whether the nth point is on the mth line between the corresponding points
% in [X1 Y1] and [X2 Y2]
  ```

<pre align="center">
  <img src=".\Images\fcn_VGraph_calculatePointsOnLines.png" alt="fcn_VGraph_calculatePointsOnLines picture" width="400" height="300">
  <figcaption>The function fcn_VGraph_calculatePointsOnLines is an inexact but fast method to check if points are on a line, within a user-given tolerance.</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

#### fcn_VGraph_convertPolytopetoDedupedPoints

this function takes in the table of all points, which in a fully tiled
field contains repeated points when a vertex belongs to multiple
polytopes, and returns a points data structure without duplicates, where
each point has an associated list of polytopes to which it belongs

 **FORMAT:**

```Matlab
% FORMAT:
%
% unique_deduped_points_struct = fcn_BoundedAStar_convertPolytopetoDedupedPoints(pointsWithData, (fig_num))
%
% INPUTS:
% pointsWithData: a-by-5 matrix of all map points, where a = number of map
% points. Note that a>=L.
% the columns in pointsWithData are as follows:
%
%   [x y point_id obs_id beg_end]
%
% see fcn_BoundedAStar_AStarBoundedSetupForTiledPolytopes for more
%
% OUTPUTS:
%
% unique_deduped_points_struct: an L-dimensional struct where L is the
% number of unique points in
%   the field with fields .x and .y for the x and y coordintes of the
%   point, respectively and .polys containing a list of all the polytope
%   ids this point is a vertex of
  ```

NOTE: this function does not appear to be completely finished as of 2025_11_08.
It is unclear where and how it is used. The assumption is that this was used
to check for situations where gaps closed between polytopes, so that path planners
could determine whether to count these "joints" as passable or not passable.

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

#### fcn_VGraph_findEdgeWeights

Finds costs associated with edges taking into account to/from pairs that
are on polytopes to inheret the minimum cost of either polytope. The
eventual goal is to allow edge "through" costs rather than perimeter "go
around" costs. The goal is to allow path planners to cut through
obstacles, at least from vertex to vertex, if cutting through is less
costly than going around. NOTE: this function is not yet done.

 **FORMAT:**

```Matlab
% FORMAT:
% [costGraph, visibilityGraph] = fcn_VGraph_findEdgeWeights...
% (polytopes, pointsWithData, gapSize, (figNum))
%
% INPUTS:
%
%   polytopes:
%
%   pointsWithData: the point matrix of all point that can be in the route, except the start and finish where
%       each row is a single point vector with data
%           x-coordinate
%           y-coordinate
%           point id
%           obstacle id (-1 if none)
%           is beginning/end of polytope (1 if yes, 0 if no)
%
%   gapSize: size of gaps between polytopes
%
%   (optional inputs)
%
%   figNum: a figure number to plot results. If set to -1, skips any
%   input checking or debugging, no figures will be generated, and sets
%   up code to maximize speed. As well, if given, this forces the
%   variable types to be displayed as output and as well makes the input
%   check process verbose
%
% OUTPUTS:
%
%    costGraph: the cost graph matrix. A cost matrix is an nxn matrix where n is
%      the number of points (nodes) in the map including the start and goal.
%      The value of element i-j is the cost of routing from i to j.
%
%    visibilityGraph: the original visibility matrix
%    corresponding to pointsWithData and the polytopes passed into the fcn
  ```

<pre align="center">
<img src=".\Images\fcn_VGraph_findEdgeWeights.png" alt="fcn_VGraph_findEdgeWeights picture" width="400" height="300">
<figcaption>The function fcn_VGraph_findEdgeWeights is a method to inheret VGraph edge weights by taking the minimum of the polytope cost of either the from or to polytope vertex.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

NOTE: this function does not appear to be completely finished as of 2025_11_08. At least, the edge costs do not plot in different colors.

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

#### fcn_VGraph_selfBlockedPoints

determines the points blocked by the obstacle containing testPointData

 **FORMAT:**

```Matlab
% FORMAT:
%
% [currentObstacleID, selfBlockedCost, pointsWithDataBlockedBySelf] = ...
% fcn_VGraph_selfBlockedPoints(polytopes, testPointData, pointsWithData, (figNum))
%
% INPUTS:
%
%   polytopes: a 1-by-n seven field structure of shrunken polytopes,
%       where n <= number of polytopes with fields:
%           vertices: a m+1-by-2 matrix of xy points with row1 = rowm+1, where m is
%           the number of the individual polytope vertices
%           xv: a 1-by-m vector of vertice x-coordinates
%           yv: a 1-by-m vector of vertice y-coordinates
%           distances: a 1-by-m vector of perimeter distances from one point to the
%           next point, distances(i) = distance from vertices(i) to vertices(i+1)
%           mean: centroid xy coordinate of the polytope
%           area: area of the polytope
%   
%   testPointData: the 1x5 array representing the current point, expected to be a vertex of a polytope
% 
%   pointsWithData: p-by-5 matrix of all the points except start and finish
%
%   (optional inputs)
%
%   figNum: a figure number to plot results. If set to -1, skips any
%       input checking or debugging, no figures will be generated, and sets
%       up code to maximize speed. As well, if given, this forces the
%       variable types to be displayed as output and as well makes the input
%       check process verbose
%
% OUTPUTS:
%
%   currentObstacleID: obstacle ID of the polytope that testPointData is a vertex of
%
%   selfBlockedCost: polytope traversal scaling of the polytope the testPointData is a vertex of
% 
%   pointsWithDataBlockedBySelf: the other vertices on the polytope that testPointData is a vertex of
%       that cannot be seen from testPointData (i.e. neither neighboring vertex which would be visible
%       by looking down the side of a convex polytope)
  ```

<pre align="center">
<img src=".\Images\fcn_VGraph_selfBlockedPoints.png" alt="fcn_VGraph_selfBlockedPoints picture" width="400" height="300">
<figcaption>The function fcn_VGraph_selfBlockedPoints identifies points on a polytope containing a test vertex that are not visible from that vertex.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

NOTE: this function does not appear to be completely finished as of 2025_11_08. At least, the edge costs do not plot in different colors.

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

#### fcn_VGraph_polytopePointsInPolytopes

checks if start or finish point(s) are within polytopes

 **FORMAT:**

```Matlab
% FORMAT:
%   
%   [flagsAtLeastOnePointIsInPoly, startPolys, finishPolys] = ...
%   fcn_VGraph_polytopePointsInPolytopes(...
%      startXY, finishXY, polytopes, ...
%      (flagThrowError), (flagEdgeCheck), (figNum))
%   
% INPUTS:
%   
%   startXY: [Nx2] vector of x and y coordinates of starting points 
%   
%   finishXY: [Nx2] vector of x and y coordinates of ending points
%   
%   polytopes: a 1-by-n seven field structure of combined polytopes, where 
%     p = number of polytopes, with fields:
%         vertices: a m+1-by-2 matrix of xy points with row1 = rowm+1, where m is
%         the number of the individual polytope vertices
%         xv: a 1-by-m vector of vertice x-coordinates
%         yv: a 1-by-m vector of vertice y-coordinates
%         distances: a 1-by-m vector of perimeter distances from one point to the
%         next point, distances(i) = distance from vertices(i) to vertices(i+1)
%         mean: average xy coordinate of the polytope
%         area: area of the polytope
%         max_radius: distance from the mean to the furthest vertex
%
% (OPTIONAL INPUTS)
%   
%   flagThrowError: flag determining whether an error should be thrown (1) for
%   points inside any polytope or no error and value assigned to ERR (0) 
%   
%   flagEdgeCheck: a flag that determines whether the polytope edges should be
%   checked for points. If set to 1, a point on the edge is considered
%   inside the polytope. Otherwise, a point on the edge is outside the
%   polytope.
%   
%   figNum: a figure number to plot results. If set to -1, skips any
%   input checking or debugging, no figures will be generated, and sets
%   up code to maximize speed. As well, if given, this forces the
%   variable types to be displayed as output and as well makes the input
%   check process verbose
%
% OUTPUTS:
%   
%   flagsAtLeastOnePointIsInPoly: [Nx1] logical vector containing, for each
%   ith start/end pair, a value of 0 if neither startXY or finishXY is in/on
%   any polytopes, 1 otherwise 
%
%   startPolys: [Nx1] vector of indicies of first polytope startXY is on.
%   Returns NaN if none.
%   
%   finishPolys: [Nx1] vector of indicies of first polytope finishXY is on.
%   Returns NaN if none.
%
%   flagsStartIsInPoly: [Nx1] vector of true if startXY is in a polytope
%
%   flagsFinishIsInPoly: [Nx1] vector of true if finishXY is in a polytope
  ```

<pre align="center">
<img src=".\Images\fcn_VGraph_polytopePointsInPolytopes.png" alt="fcn_VGraph_polytopePointsInPolytopes picture" width="400" height="300">
<figcaption>The function fcn_VGraph_polytopePointsInPolytopes identifies whether start/finish points are within polytopes.</figcaption>
<!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

### Core Functions

#### fcn_VGraph_clearAndBlockedPoints

The function fcn_VGraph_clearAndBlockedPoints is the core function for this repo finds the visbility from one point to many other points in a polytope map.

<pre align="center">
  <img src=".\Images\fcn_VGraph_clearAndBlockedPoints.png" alt="fcn_VGraph_clearAndBlockedPoints picture" width="400" height="300">
  <figcaption>Fig.4 - The function fcn_VGraph_clearAndBlockedPoints is the core function in the repo, and finds visibility from one point to many other points.</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

 **FORMAT:**

```Matlab
% FORMAT: 
% [clear_pts,blocked_pts,D,di,dj,num_int,xiP,yiP,xiQ,yiQ,xjP,yjP,xjQ,yjQ] = ...
% fcn_VGraph_clearAndBlockedPoints(polytopes, start, finish, (isConcave), (figNum))
%
% INPUTS:
%
%   polytopes: a 1-by-p seven field structure of polytopes, where
%   p = number of polytopes, with fields:
%       vertices: a v+1-by-2 matrix of xy points with row1 = rowv+1, where v is
%           the number of the individual polytope vertices
%       xv: a 1-by-v vector of vertice x-coordinates
%       yv: a 1-by-v vector of vertice y-coordinates
%       distances: a 1-by-v vector of perimeter distances from one point to the
%           next point, distances(i) = distance from vertices(i) to vertices(i+1)
%       mean: average xy coordinate of the polytope
%       area: area of the polytope
%       max_radius: distance from the mean to the furthest vertex
%
%   start: a 1-by-5 vector of starting point information, including:
%       x-coordinate
%       y-coordinate
%       point id number
%       obstacle id number
%       beginning/ending indication (1 if the point is a beginning or ending
%           point and 0 otherwise)
%       Ex: [x y point_id obs_id beg_end]
%
%   finish:  a m-by-5 vector of ending points information, including the
%   same information as START
%
%   (optional inputs)
%
%   isConcave: set a 1 to allow for concave (i.e. non-convex) obstacles. If
%   this is left
%       blank or set to anyting other than 1, the function defaults to the
%       convex behavior which is more conservative (i.e. setting the flag
%       wrong incorrectly may result in suboptimal paths but not
%       collisions). For background on what this flag does, see slides 9-14
%       here (for IVSG members):
%       //IVSG/Theses/2025_Harnett_PhD/Weekly%20Updates/HARNETT_WEEKLY_UPDATE_JAN08_2024.pptx
%
%   figNum: a figure number to plot results. If set to -1, skips any
%       input checking or debugging, no figures will be generated, and sets
%       up code to maximize speed. As well, if given, this forces the
%       variable types to be displayed as output and as well makes the input
%       check process verbose
%
% OUTPUTS:
%   
%   clear_pts: finish points that are not blocked by any obstacle with the
%   same information as FINISH
%
%   blocked_pts: finish points that are not blocked by any obstacle with the
%   same information as FINISH
%
%   D: m-by-n intersection array, where m = number of finish points
%       and n = number of polytope edges, where 1 indicates that an
%       intersection occures between the START and FINISH point on the
%       corresponding polytope edge and 0 indicates no intersection
%
%   di: m-by-n intersection array, where each value gives the percentage of
%   how far along the path from START to FINISH the intersection occurs
%
%   dj: m-by-n intersection array, where each value gives the percentage of
%   how far along the polytope edge the intersection occurs
%
%   num_int: m-by-1 vector of the number of intersections between the START
%   and each point in FINISH
%
%   xiP: m-by-1 vector of the x-coordinates of the starting point of
%   potential paths
%
%   yiP: m-by-1 vector of the y-coordinates of the starting point of
%   potential paths
%
%   xiQ: m-by-1 vector of the x-coordinates of the finishing points of
%   potential paths
%
%   yiQ: m-by-1 vector of the y-coordinates of the finishing points of
%   potential paths
%
%   xjP: 1-by-n vector of the x-coordinates of the starting point of the
%   polytope edge
%
%   yjP: 1-by-n vector of the y-coordinates of the starting point of the
%   polytope edge
%
%   xjQ: 1-by-n vector of the x-coordinates of the finishing point of the
%   polytope edge
%
%   yjQ:  1-by-n vector of the y-coordinates of the finishing point of the
%   polytope edge
```

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

#### fcn_VGraph_clearAndBlockedPointsGlobal

The function fcn_VGraph_clearAndBlockedPointsGlobal calls, over all points (global), the function
fcn_VGraph_clearAndBlockedPoints. That subfunction returns an
intersection matrix for a single start point, showing what was
intersected between that start point and numerous possible end points.
This "global" function wraps that function to call it on every possible
start and end combination to provide global visibility truth tables
rather than local intersection truth tables.

<pre align="center">
  <img src=".\Images\fcn_VGraph_clearAndBlockedPointsGlobal.png" alt="fcn_VGraph_clearAndBlockedPointsGlobal picture" width="400" height="300">
  <figcaption>Fig.4 - The function fcn_VGraph_clearAndBlockedPointsGlobal finds the visibility matrix of a map.</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

<pre align="center">
  <img src=".\Images\fcn_VGraph_clearAndBlockedPointsGlobal_vGraphAnimation.gif" alt="fcn_VGraph_clearAndBlockedPointsGlobal animation" width="400" height="300">
  <figcaption>Fig.4 - The function fcn_VGraph_clearAndBlockedPointsGlobal, animated.</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

 **FORMAT:**

```Matlab
% FORMAT:
% [visibilityMatrix, visibilityDetailsEachFromPoint] = ...
% fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, (isConcave), (figNum))
%
% INPUTS:
%
%     polytopes: a 1-by-p seven field structure of polytopes, where
%       p = number of polytopes, with fields:
%       vertices: a v+1-by-2 matrix of xy points with row1 = rowv+1, where v is
%           the number of the individual polytope vertices
%       xv: a 1-by-v vector of vertice x-coordinates
%       yv: a 1-by-v vector of vertice y-coordinates
%       distances: a 1-by-v vector of perimeter distances from one point to the
%           next point, distances(i) = distance from vertices(i) to vertices(i+1)
%       mean: average xy coordinate of the polytope
%       area: area of the polytope
%       max_radius: distance from the mean to the furthest vertex
%
%     starts: p-by-5 matrix of all the possible start points
%       the information in the 5 columns is as follows:
%         x-coordinate
%         y-coordinate
%         point id numberf
%         obstacle id number
%         beginning/ending indication (1 if the point is a beginning or ending
%         point and 0 otherwise)
%         Ex: [x y point_id obs_id beg_end]
%
%      finishes: p-by-5 matrix of all the possible finish points
%       the information in the 5 columns is as follows:
%         x-coordinate
%         y-coordinate
%         point id numberf
%         obstacle id number
%         beginning/ending indication (1 if the point is a beginning or ending
%         point and 0 otherwise)
%         Ex: [x y point_id obs_id beg_end]
%
%     (optional inputs)
%
%      isConcave: set a 1 to allow for concave (i.e. non-convex) obstacles.  If this is left
%         blank or set to anyting other than 1, the function defaults to the convex behavior
%         which is more conservative (i.e. setting the flag wrong incorrectly may result in
%         suboptimal paths but not collisions). For background on what this flag does, see slides
%         in `concave_vgraph` section of Documentation/bounded_astar_documentation.pptx
%
%      figNum: a figure number to plot results. If set to -1, skips any
%         input checking or debugging, no figures will be generated, and sets
%         up code to maximize speed. As well, if given, this forces the
%         variable types to be displayed as output and as well makes the input
%         check process verbose
%
% OUTPUTS:
%
%     visibilityMatrix: nxn matrix, where n is the number of points in all_pts
%       a 1 in column i and row j indicates that all_pts(i,:) is visible from
%       all_pts(j,:).  This matrix is therefore symmetric
%
%     visibilityDetailsEachFromPoint: an array of structures containing
%     visibilty information for each "from" point. The structure passes out
%     all output arguments for the function
%     fcn_VGraph_clearAndBlockedPoints per each "from" point call.
```

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

#### fcn_VGraph_addObstacle

Recalculates the visibility graph after adding a polytope without
recalculating the entire visibility graph.  This is accomplished using
an AABB check as a coarse check. This function also recalculates the
pointsWithData, startPointData, finishPointData, and polytopes data
structures as these are also affected by the addition of an obstacle.
See vgraph_modification section of
Documentation/bounded_astar_documentation.pptx for pseudocode and
algorithm description

<pre align="center">
  <img src=".\Images\fcn_VGraph_addObstacle.png" alt="fcn_VGraph_addObstacle picture" width="400" height="300">
  <figcaption>Fig.4 - The function fcn_VGraph_addObstacle finds the visibility matrix after an obstacle has been added.</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

 **FORMAT:**

```Matlab
% FORMAT:
%     [newVisibilityMatrix, newPointsWithData, newStartPointData, newFinishPointData, newPolytopes] = ...
%     fcn_VGraph_addObstacle(...
%     visibilityMatrix, pointsWithData, startPointData, finishPointData, polytopes, polytopeToAdd, (figNum))
%
% INPUTS:
%
%     visibilityMatrix - nxn matrix, where n is the number of points in pointsWithData
%       a 1 in column i and row j indicates that pointsWithData(i,:) is visible from
%       pointsWithData(j,:).  This matrix is therefore symmetric
%
%     pointsWithData: p-by-5 matrix of all the possible start points
%       the information in the 5 columns is as follows:
%         x-coordinate
%         y-coordinate
%         point id number
%         obstacle id number
%         beginning/ending indication (1 if the point is a beginning or ending
%         point and 0 otherwise)
%         Ex: [x y point_id obs_id beg_end]
%
%     startPointData: 1-by-5 vector with the same info as route for the starting point
%     
%     finishPointData: same as startPointData for the finish point
%     
%     polytopes - the polytope struct array prior to modification EXCLUDING the polytope for additionk
%     
%     polytopeToAdd - struct of the polytope to add
%
%     (optional inputs)
%
%     figNum: a figure number to plot results. If set to -1, skips any
%         input checking or debugging, no figures will be generated, and sets
%         up code to maximize speed. As well, if given, this forces the
%         variable types to be displayed as output and as well makes the input
%         check process verbose
%
% OUTPUTS:
%
%     newVisibilityMatrix: same as the visiblity_matrix input but modified so that the added
%         polytope now affects the visibility.  Note this may have more points than
%         the input matrix as points on the added polytope are now considered as nodes.
%
%     newPointsWithData: same as the pointsWithData input but with points on the added polytope.
%         May be reindexed.
%     
%     newStartPointData: same as startPointData input but reindexed to account for added points
%     
%     newFinishPointData: same as finishPointData input but reindexed to account for added points
%     
%     newPolytopes:  the polytope struct array after modification now including
%         the polytope for addition
```

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

#### fcn_VGraph_removeObstacle

  Recalculates the visibility graph after deleting a polytope without
  recalculating the entire visibility graph.  This is accomplished using
  an AABB check as a coarse check. This function also recalculates the
  pointsWithData, startPointData, finishPointData, and polytopes data
  structures as these are also affected by the removal of an obstacle.

  See vgraph_modification section of
  Documentation/bounded_astar_documentation.pptx for pseudocode and
  algorithm description

<pre align="center">
  <img src=".\Images\fcn_VGraph_removeObstacle.png" alt="fcn_VGraph_removeObstacle picture" width="400" height="300">
  <figcaption>Fig.4 - The function fcn_VGraph_removeObstacle finds the visibility matrix after an obstacle has been removed.</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

 **FORMAT:**

```Matlab
% FORMAT:
%
% [newVisibilityMatrix, newPointsWithData, newStartPointData, newFinishPointData, newPolytopes] = ...
%     fcn_VGraph_removeObstacle(...
%     visibilityMatrix, pointsWithData, startPointData, finishPointData, polytopes, indexOfPolytopeForRemoval, (figNum))
%
% INPUTS:
%
%     visibilityMatrix: nxn matrix, where n is the number of points in pointsWithData
%       a 1 in column i and row j indicates that pointsWithData(i,:) is visible from
%       pointsWithData(j,:).  This matrix is therefore symmetric
%     
%     pointsWithData: p-by-5 matrix of all the polytope points
%       the information in the 5 columns is as follows:
%         x-coordinate
%         y-coordinate
%         point id number
%         obstacle id number
%         beginning/ending indication (1 if the point is a beginning or ending
%         point and 0 otherwise)
%         Ex: [x y point_id obs_id beg_end]
%     
%     startPointData: 1-by-5 vector with the same info as route for the starting point
%     
%     finishPointData: same as startPointData for the finishPointData point
%
%     polytopes: the polytope struct array prior to modification INCLUDING the polytope for removal
%     
%     indexOfPolytopeForRemoval: the index of the polytope to be removed in the polytopes struct array
%
%     (optional inputs)
%
%     figNum: a figure number to plot results. If set to -1, skips any
%         input checking or debugging, no figures will be generated, and sets
%         up code to maximize speed. As well, if given, this forces the
%         variable types to be displayed as output and as well makes the input
%         check process verbose
%
% OUTPUTS:
%     newVisibilityMatrix: same as the visiblity_matrix input but modified so that the removed
%         removed polytope no longer affects the visibility.  Note this may have fewer points than
%         the input matrix as points on the removed polytope are deleted.
%
%     newPointsWithData: same as the pointsWithData input but with points on the removed polytope deleted.
%         May be reindexed
%
%     newStartPointData: same as startPointData input but reindexed to account for removed points
%     
%     newFinishPointData: same as finishPointData input but reindexed to account for removed points
%     
%     newPolytopes:  the polytope struct array after modification no longer including
%         the polytope for removal
```

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

#### fcn_VGraph_generateDilationRobustnessMatrix

This function operates on a visibility graph formed from a polytope map
to estimate the distance, for each vgraph edge, that the polytopes would
have to be dilated to block that edge. This is similar to corridor width
except (1) it is only an estimate, the actual corridor around the vgraph
edge is not measured/calculated and (2) the distance is measured to each
side independently meaning it is more accurate to think of it as the
lateral distance from the vgraph edge to the nearest polytope, rather
than thinking of it as the width of the corridors between polytopes.  For
a better approximate of corridor width please see the medial axis graph
structure. see dilation_robustness section of
Documentation/bounded_astar_documentation.pptx for pseudocode and
algorithm description

<pre align="center">
  <img src=".\Images\fcn_VGraph_generateDilationRobustnessMatrix.png" alt="fcn_VGraph_generateDilationRobustnessMatrix picture" width="400" height="300">
  <figcaption>The function fcn_VGraph_generateDilationRobustnessMatrix estimates edge clearances around each edge in a visibility matrix.</figcaption>
  <!--font size="-2">Photo by <a href="https://unsplash.com/ko/@samuelchenard?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Samuel Chenard</a> on <a href="https://unsplash.com/photos/Bdc8uzY9EPw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></font -->
</pre>

 **FORMAT:**

```Matlab
% FORMAT:
%
%      dilation_robustness_matrix = ...
%      fcn_VGraph_generateDilationRobustnessMatrix(...
%      all_pts, start, finish, vgraph, mode, polytopes,...
%      (plottingOptions), (figNum))
%
% INPUTS:
%
%     start: the start point vector
%         Format:
%         2D: (x,y,point_id, -1, 1)
%         3D: (x,y,z,point_id, -1, 1)
%
%     finish: the finish point matrix of all valid finishes where each row is a single finish point
%       vector.
%         Format:
%         2D: (x,y,point_id, -1, 1)
%         3D: (x,y,z,point_id, -1, 1)
%
%     all_pts: the point matrix of all point that can be in the route, except the start and finish where
%         each row is a single point vector.
%         Format:
%         2D: (x,y,point_id, poly_id, 1 if point is start/end on poly, 0 otherwise)
%         3D: (x,y,z,point_id, poly_id, 1 if point is start/end on poly, 0 otherwise)
%
%     vgraph: the visibility graph as an nxn matrix where n is the number of points (nodes) in the map.
%         A 1 is in position i,j if point j is visible from point i.  0 otherwise.
%
%     mode: a string for what dimension the inputs are in. The mode argument must be a string with
%       one of the following values:
%         - "3D" - this implies xyz or xyt space
%         - "2D" - this implies xy spatial only dimensions only
%
%     polytopes: polytope struct array
%        polytopes: an array of structures containing polytope information.
%
%      (OPTIONAL INPUTS)
%
%      plottingOptions: allows user to set plotting options particular to
%      this function. These include:
%          plottingOptions.axis
%          plottingOptions.selectedFromToToPlot: the [from to] edge to plot
%          plottingOptions.maxScalingValue: the normalization value
%
%      fig_num: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      dilation_robustness_matrix - nxnx2 matrix where n is the number of
%      points (nodes) in the map. The value of element i,j,k is the
%      estimated coridor width surrounding the line segment from point i to
%      point j.  The third index, k, is 1 if the free space is measured to
%      the left hand side when facing the j from i, or k = 2 if measured to
%      the right hand side .
```

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

<!-- USAGE EXAMPLES -->
## Usage
<!-- Use this space to show useful examples of how a project can be used.
Additional screenshots, code examples and demos work well in this space. You may
also link to more resources. -->

### General Usage

Each of the functions has an associated test script, using the convention

```sh
script_test_fcn_fcnname
```

where fcnname is the function name as listed above.

As well, each of the functions includes a well-documented header that explains inputs and outputs. These are supported by MATLAB's help style so that one can type:

```sh
help fcn_fcnname
```

for any function to view function details.

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

### Examples

1. Run the main script to set up the workspace and demonstrate main outputs, including the figures included here:

   ```sh
   script_demo_VGraph
   ```

    This demonstrates the main functionaliteis of this repo

2. After running the main script to define the included directories for utility functions, one can then navigate to the Functions directory and run any of the functions or scripts there as well. All functions for this library are found in the Functions sub-folder, and each has an associated test script. Run any of the various test scripts - each should run as stand-alone scripts.

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

## Major release versions

This code is still in development (alpha testing)

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

<!-- CONTACT -->
## Contact

Sean Brennan - sbrennan@psu.edu

Project Link: [https://github.com/ivsg-psu/PathPlanning_GridFreePathPlanners_VGraph](https://github.com/ivsg-psu/PathPlanning_GridFreePathPlanners_VGraph)

<a href="#pathplanning_gridfreepathplanners_vgraph">Back to top</a>

***

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
