Name:           dvtm-plus
Version:        0.17.0dev
Release:        5%{?dist}
Summary:        Configurable tiling window management for the console
License:        MIT and ISC
URL:            http://www.brain-dump.org/projects/%{name}/
Source0:        http://www.brain-dump.org/projects/%{name}/%{name}-%{version}.tar.gz
Patch0:         %{name}-0.17-build.patch
BuildRequires:  binutils
BuildRequires:  coreutils
BuildRequires:  gcc
BuildRequires:  make
BuildRequires:  ncurses
BuildRequires:  ncurses-devel
BuildRequires:  sed

%description
dvtm-plus brings the concept of tiling window management, popularized by
X11-window managers like dwm to the console. It is an enhancement
to dvtm. As a console window
manager it tries to make it easy to work with multiple console based
programs like vim, mutt, cmus or irssi. Unlike dvtm and dwm, dvtm-plus has
a configuration file ~/.dvtm-plus/config that allows you to configure the keys
or environment variables.

%prep
%setup -q
%patch0 -p1 -b .build

%build
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot} PREFIX=%{_prefix}

%files
%license LICENSE
%doc README.md
%{_bindir}/%{name}
%{_bindir}/%{name}-status
%{_mandir}/man1/%{name}.1*
%{_datadir}/terminfo/d

%changelog
* Wed Aug 02 2017 Fedora Release Engineering <releng@fedoraproject.org> - 0.15-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Binutils_Mass_Rebuild

* Wed Jul 26 2017 Fedora Release Engineering <releng@fedoraproject.org> - 0.15-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Fri Feb 10 2017 Fedora Release Engineering <releng@fedoraproject.org> - 0.15-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Wed Feb 03 2016 Fedora Release Engineering <releng@fedoraproject.org> - 0.15-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Fri Jan 15 2016 Petr Šabata <contyk@redhat.com> - 0.15-1
- 0.15 bump

* Thu Sep 17 2015 Petr Šabata <contyk@redhat.com> - 0.14-4
- Fix the build patch to enable full RELRO

* Thu Jun 25 2015 Petr Šabata <contyk@redhat.com> - 0.14-3
- Correct the dep list
- Modernize spec

* Wed Jun 17 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.14-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Fri Feb 20 2015 Petr Šabata <contyk@redhat.com> - 0.14-1
- 0.14 bump

* Tue Nov 18 2014 Petr Šabata <contyk@redhat.com> - 0.13-1
- 0.13 bump

* Sat Aug 16 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.12-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Tue Jul 15 2014 Petr Šabata <contyk@redhat.com> - 0.12-1
- 0.12 bump

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.11-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Tue Mar 11 2014 Petr Šabata <contyk@redhat.com> - 0.11-1
- 0.11 enhancement bump

* Mon Jan 06 2014 Petr Šabata <contyk@redhat.com> - 0.10-1
- 0.10 bugfix and enhancement bump

* Sat Aug 03 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.9-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Wed Apr 03 2013 Petr Šabata <contyk@redhat.com> - 0.9-1
- 0.9 bump, various new enhancements
- We now ship our own terminfo

* Wed Feb 13 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.8-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Wed Aug 01 2012 Petr Šabata <contyk@redhat.com> - 0.8-1
- Update to 0.8

* Wed Jul 18 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.7-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Fri Jan 13 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.7-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Mon Sep 05 2011 Petr Sabata <contyk@redhat.com> - 0.7-1
- Update to 0.7
- Change license of the terminal component to ISC
- Drop now obsolete BuildRoot and defattr

* Tue Feb 08 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.5.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Thu Aug 06 2009 Rakesh Pandit <rakesh@fedoraproject.org> - 0.5.2-1
- Updated to 0.5.2

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.5.1-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Thu Jun 04 2009 Rakesh Pandit <rakesh@fedoraproject.org> 0.5.1-5
- Removed LGPLv2 copy

* Thu Jun 04 2009 Rakesh Pandit <rakesh@fedoraproject.org> 0.5.1-4
- Updated Makefile patch to echo current execution lines for
-  dvtm.c and madtty.c and added LGPLv2 txt file

* Fri May 22 2009 Rakesh Pandit <rakesh@fedoraproject.org> 0.5.1-3
- Fixed license tag

* Sun May 10 2009 Rakesh Pandit <rakesh@fedoraproject.org> 0.5.1-2
- Removed -stripping from binaries and saving timestamp while
- installing via Makefile patch.

* Sun May 10 2009 Rakesh Pandit <rakesh@fedoraproject.org> 0.5.1-1
- Initial package
