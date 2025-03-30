Name:       com.modus.fashion
Summary:    MyModus
Version:    1.0.1
Release:    11
Group:      Qt/Qt
License:    BSD-3-Clause
URL:        https://mymodus.ru
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(aurorawebview)
BuildRequires:  pkgconfig(auroraapp)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Network)

%description
Our story began in 2014 with the first collection of swimsuits and beach tunics made of chiffon and silk. Gradually, our brand grew, gained momentum and expanded its range. Now My Modus is a team of professionals working on creating collections. And now every woman can choose from us both casual clothes and clothes for business, evening events etc.

%prep
%autosetup

%build
%qmake5
%make_build

%install
%make_install

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%defattr(644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
