"""This module is a collection of dput-ng hooks that catches common issues."""

import re

from distro_info import UbuntuDistroInfo
from dput.exceptions import HookException
from termcolor import colored


def stop(message):
    """ Raise a HookException to stop the upload and add the message in red """
    raise HookException(colored('STOP: %s' % message, 'red'))


def warn(message):
    """ Print a warning in yellow """
    print(colored('WARNING: %s' % message, 'yellow'))


def ask(interface, question, default="no"):
    """ Interact with the user asking (in green) if we should continue """
    return interface.boolean(title='Check',
                             message=(colored(question, "green")),
                             default=default)


def check_for_placeholder(changes, profile, interface):
    """
    Many of us use placeholder bugs *9999* or 1234* but uploading with that in
    the changelog is wrong. So block if that bug is in the changes file.
    """
    if 'Launchpad-Bugs-Fixed' not in changes:
        return
    bugsfixed = changes['Launchpad-Bugs-Fixed']
    bugs = bugsfixed.split()
    placeholders = ['1234', '9999']
    foundplaceholder = False
    for bug in bugs:
        for placeholder in placeholders:
            if bug.startswith(placeholder):
                warn(f'bug {bug} starts with '
                     f'potential placeholder {placeholder}')
                foundplaceholder = True
    if foundplaceholder:
        if not ask(interface, 'Upload with potential placeholder?'):
            stop('bug contains placeholder bugs')


def check_for_ppa_to_nonppa(changes, profile, interface):
    """
    If the version contains a ppa suffix that likely is not meant to be
    uploaded to the ubuntu archive.
    """
    version = changes['Version']
    version_contains_ppa = re.match(r'.*~\w*ppa\d*$', version)

    if profile['name'] == "ppa":
        if not version_contains_ppa:
            warn('PPA upload - version %s does not contain'
                 ' common ~ppa suffix' % version)
            if not ask(interface, 'Upload without ppa suffix?'):
                stop('PPA upload "%s" does not contain ~ppa' % version)
    else:
        if version_contains_ppa:
            warn('Archive upload - version %s contains'
                 ' common ~ppa suffix' % version)
            stop('Ubuntu upload "%s" contains ~ppa' % version)


def bad_author(changes, profile, interface):
    """
    If built in a LXD or a VM bad emails might end up signing the upload.
    By sponsoring them you'd push these bad emails into the archive.
    """
    author = changes['Changed-By']
    if 'ubuntu@' in author or 'root@' in author:
        warn('email contains ubuntu@ or root@')
        stop('STOP: Bad email in Changed-By "%s"' % author)


def nobug(changes, profile, interface):
    """
    Not always, but often it is wrong to upload without any bug reference.
    """
    if 'Launchpad-Bugs-Fixed' not in changes:
        warn('No bugs marked as closed!')
        if not ask(interface, 'Upload without bug references?'):
            stop('STOP: No bugs referenced!')


def check_update_maintainer(changes, profile, interface):
    """
    If the version mentions Ubuntu changes, most likely update-maintainer
    should have been run. This is similar to the check by dpkg-buildpkg.
    """
    version = changes['Version']
    if re.match(r'.*\dubuntu\d*$', version):
        maint = changes['Maintainer']
        if not re.match(r'.*@.*ubuntu.com>$', maint):
            warn('Upload without @ubuntu.com maintainer (%s)' % maint)
            if not ask(interface, 'Upload without bad maintainer?'):
                stop('STOP: bad maintainer!')


def check_git_ubuntu(changes, profile, interface):
    """
    Check if the git-ubuntu Vcs-* entries are present, since most of our
    uploads in the Server Team are meant to go with those warn and ask if not.
    """
    vcsentries = ['Vcs-Git', 'Vcs-Git-Commit', 'Vcs-Git-Ref']
    vsmissing = False
    for vcsentry in vcsentries:
        if vcsentry not in changes:
            warn('.changes file does not contain git-ubuntu "%s"' % vcsentry)
            vsmissing = True
    if vsmissing:
        if not ask(interface, 'Upload without git-ubuntu Vcs entries?'):
            stop('STOP: git-ubuntu Vcs entries missing!')


def check_release_mismatch(changes, profile, interface):
    """
    Check if one of the common backport suffixes like ...20.10... does not
    match the target release e.g. Focal which should be 20.04
    """
    version = changes['Version']
    if not re.match(r'.*\d\d.\d\d.*', version) or 'ubuntu' not in version:
        return
    ubuntu_version = version.split('ubuntu')[1]
    xxyy_elements = re.findall(r'(?=(\d\d\.\d\d))', ubuntu_version)
    if not xxyy_elements:
        return

    # focal, focal-security, focal-proposed, ...
    codename = changes['Distribution'].split('-')[0]
    ubuntu_distro_info = UbuntuDistroInfo()
    # can return "20.10" or "20.04 LTS"
    target_xxyy = ubuntu_distro_info.version(codename).split()[0]

    badrelease = False
    for xxyy in xxyy_elements:
        if xxyy != target_xxyy:
            warn(f'Ubuntu version of {version} contains {xxyy}'
                 ' which does not match target'
                 f' ({codename} => {target_xxyy})')
            badrelease = True

    if badrelease:
        if not ask(interface, 'Upload without XX.YY not matching release?'):
            stop('STOP: XX.YY not matching target release!')
