import ManagedSettings
import ManagedSettingsUI
import UIKit

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        let appName = application.localizedDisplayName ?? localized("shield.app.fallbackName")
        return makeConfiguration(
            title: localized("shield.title.app"),
            subtitle: String(format: localized("shield.subtitle.app"), appName)
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration(
            title: localized("shield.title.appCategory"),
            subtitle: localized("shield.subtitle.appCategory")
        )
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        let domainName = webDomain.domain ?? localized("shield.website.fallbackName")
        return makeConfiguration(
            title: localized("shield.title.website"),
            subtitle: String(format: localized("shield.subtitle.website"), domainName)
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration(
            title: localized("shield.title.websiteCategory"),
            subtitle: localized("shield.subtitle.websiteCategory")
        )
    }

    private func makeConfiguration(title: String, subtitle: String) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemChromeMaterialDark,
            backgroundColor: UIColor(red: 0.06, green: 0.07, blue: 0.13, alpha: 1.0),
            icon: shieldIcon,
            title: ShieldConfiguration.Label(
                text: title,
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: subtitle,
                color: UIColor(white: 1.0, alpha: 0.8)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: localized("shield.button.close"),
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor.systemBlue
        )
    }

    private func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: .main, comment: "")
    }

    private var shieldIcon: UIImage? {
        UIImage(named: "rituo.logo", in: hostAppBundle, compatibleWith: nil)
            ?? UIImage(systemName: "lock.shield.fill")
    }

    private var hostAppBundle: Bundle? {
        let appBundleURL = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return Bundle(url: appBundleURL)
    }
}
