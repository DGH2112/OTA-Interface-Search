(**

  This module contains constants (mainly regular expressions) for use throughout the applications.

  @Author  David Hoyle
  @Version 1.0
  @Date    12 Jan 2020

  @license

    OTA Interface Search is a RAD Studio application for searching the RAD Studio
    Open Tools API source (not included) for properties and methods to expose the
    required interfaces / methods / properties and provide (if possible) the path
    through the OTA in order to use the interface / method / property.
    
    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/OTA-Interface-Search)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

**)
Unit OTAIntfSearch.Constants;

Interface

Const
  (** A regular expression for finding interface declarations. **)
  strInterfaceRegEx             = '^\s*I\w*\s*=\s*\binterface\b';
  (** A regular expression for finding class declarations. **)
  strClassRegEx                 = '^\s*T\w*\s*=\s*\bclass\b';
  (** A regular expression for finding procedure declarations **)
  strProcedureStartRegEx        = '^( |\t)*Procedure *';
  (** A regular expression for finding function declarations **)
  strFunctionStartRegEx         = '^( |\t)*Function *';
  (** A regular expression for finding property declarations **)
  strPropertyStartRegEx         = '^( |\t)*Property *';
  (** A regular expression for finding both interface and class declarations **)
  strInterfaceObjectStartRegEx  = strInterfaceRegEx + '|' + strClassRegEx;
  (** A regular expression for finding function, procpedure and property declarations. **)
  strMethodPropertyStartRegEx   = strFunctionStartRegEx + '|' + strProcedureStartRegEx + '|' +
    strPropertyStartRegEx;
  (** A regular expression for finding the end statement for an interface or class. **)
  strEndRegEx                   = '^( |\t)*end *; *$';
  (** A regular expression for finding single line comments. **)
  strSingleLineCommentRegEx     = '^( |\t)*\{[^\$].*\} *$';
  (** A regular expression for finding a multi-line comments end. **)
  strMultiLineCommentEndRegEx   = '^( |\t)*[^\{][^\$].*\} *$';
  (** A regular expression for finding a multi-line comments start. **)
  strMultiLineCommentStartRegEx = '^( |\t)*\{[^\$].*$';
  (** A regular expression for finding method (function and procedure) declarations. **)
  strMethodStartRegEx           = strProcedureStartRegEx + '|' + strFunctionStartRegEx;
  (** A regular expression for finding an opening parenthesis.**)
  strOpenParenthesisRegEx       = '.*\(.*';
  (** A regular expression for finding an closing parenthesis.**)
  strCloseParenthesisRegEx      = '.*\).*';
  (** A regular expression for finding a ending semi-colon. **)
  strEndingSemiColonRegEx       = '.*; *$';
  (** A regular expression for finding functions and properties which return specific
      identifiers. **)
  (** A regular expression for checking an identifier for being a service interface. **)
  strServiceRegEx               = '^( |\t)*I[a-z]+Services[^0-9]*$';
  (** A regular expression for finding interface and class identifiers. **)
  strInterfaceClassIdentifier   = '[IT][a-z]+';
  (** A regular expression for finding a general identifier. **)
  strGeneralIdentifier          = '[a-z][a-z0-9]+';
  (** A regular expression for finding methods for adding notifiers. **)
  strNotifierSearchRegEx        = 'AddNotifier\( *(|const) *[a-z][a-z0-9]* *: *%s *\)';
  (** A regular expression for finding interfaces returned from functions and properties. **)
  strMethodInterfaceSearch      = '(^( |\t)*function *[a-z][a-z0-9]+( *|\().*: *I[ON]TA[a-z0-9]+;$|' +
                                   '^( |\t)*property *[a-z][a-z0-9]+( *|\[).*: *I[ON]TA[a-z0-9]+)';
  (** This is a constant array of string pairs that denote interfaces that can be queried for from
      another interface, for instance: Module.QueryInterface(IOTAProjectGroup, ProjectGroup). **)
  strQueryInterfaces : Array[1..3, 1..2] Of String = (
    ('IOTAProjectGroup', 'IOTAModule'),
    ('IOTAProject', 'IOTAModule'),
    ('IOTASourceEditor', 'IOTAEditor')
  );

Implementation

End.
